require 'json'
require 'net/http'
require 'uri'

module MasterManipulator
  module Service
    # Restart the puppet server and wait for it to come back up
    # ==== Attributes
    # *+host+ - the host that this should operate on
    # *+opts+ - an options hash - not required
    #   *+:wait_cycle+ - the number of cycles to attempt retry
    #   *+:is_pe?+ - Boolean : if the SUT is PE, defaults to true
    #   *+:hup?+ - Boolean : if true, reload server; if false, restart server; defaults to false
    #
    # Raises a standard error if the wait is unsuccessful
    #
    # ==== Example
    # restart_puppet_server(master)
    # restart_puppet_server(master, {:wait_cycles => 20})
    # restart_puppet_server(master, {:is_pe? => false, :hup? => true})
    def restart_puppet_server(host, opts = {:is_pe? => true, :hup? => false})
      start_time = Time.now

      if :hup?.class != TrueClass && :hup?.class != FalseClass
        raise TypeError, ':hup? must be boolean (true/false)'
      end

      opts[:is_pe?] ? service_name = 'pe-puppetserver' : service_name = 'puppetserver'
    
      if opts[:hup?]
        hup_service(host, service_name)
        return
      else
        on(host, puppet("resource service #{service_name} ensure=stopped"))
        on(host, puppet("resource service #{service_name} ensure=running"))
      end

      if opts[:is_pe?]
        opts[:wait_cycles] ||= 10
        pe_ver = pe_version(host)
        three_eight_regex = /^3\.8/
        
        # FIXME: This logic is not ideal refactor in the future
        # if its PE and not 3.8 use the status endpoint
        # it its not PE or it is 3.8 use the simple curl call
        # FIXME: Replace curl calls with http_request calls
        hostname = host.hostname
        if !pe_ver.match(three_eight_regex)
          curl_call = "--head --insecure https://#{hostname}:8140"
        else
          curl_call = "--insecure --request GET --header 'Content-Type: application/json' https://#{hostname}:8140/status/v1/services?level=debug"
        end

        (1..opts[:wait_cycles]).each do |i|
          @result = curl_on(host, curl_call, :acceptable_exit_codes => [0,1,7])
          # parse body if we are using PE and we are not in PE 3.8
          @body = (pe_ver && !pe_ver.match(three_eight_regex)) ? JSON.parse(@result.stdout) : []
          
          case @result.exit_code.to_s
          when '0'
            sleep 20
            pe_ver.match(/three_eight_regex/) ? return : (return if @body.all? { |k, v| v['state'] == 'running' })
          when '1', '7'
            # Exit code 7 is "connection refused"
            sleep (i**(1.2))
          end
        end

        total_time = Time.now - start_time
        
        message = "Attempted to restart #{opts[:wait_cycles]} times, " +
          "waited #{total_time} seconds total. \nHere is the status " +
          "reported by the puppetserver:\n"
        @body.each do |k,v|
          message << "\n'#{k}' state: #{v['state']} "
        end
        raise message
      end
    end

    # Send SIGHUP to service_name on host and wait for reload to complete
    # ==== Attributes
    # *+host+ - the host that this should operate on
    # *+service_name+ - the service to restart
    #
    # ==== Example
    # hup_service(master, 'puppetserver')
    # hup_service(host, 'pe-puppetserver')
    def hup_service(host, service_name)
      timeout = 30

      # FIXME: This should be replaced either by invoking "puppetserver reload"
      # after EZ-68 gets merged
      pid = on(host, "pgrep -fo #{service_name}").stdout.strip
      on(host, "kill -HUP #{pid}")
      sleep timeout

      # FIXME This should use the new status endpoint /status/v1/services?level=debug"
      url = "https://#{host}:8140/puppet/v3/status"
      cert = get_cert(host)
      key = get_key(host)
      response_code = "0"
      sleeptime = 1
      while response_code != "200" && timeout > 0
        sleep sleeptime
        begin
          response = https_request(url, 'GET', cert, key)
        rescue StandardError => e
          expected_errors = [ EOFError, Errno::ECONNREFUSED, Errno::ECONNRESET,
                              OpenSSL::SSL::SSLError ]
          if !expected_errors.include?e.class
            raise e
          else
            puts "Ignoring expected exception #{e}; server is restarting"
          end
        end
        response_code = response.code unless response == nil
        timeout = timeout - sleeptime
      end      
    end
    
    # Fetch the host cert from the specified host and return it as an
    # OpenSSL::X509::Certificate object
    # ==== Attributes
    # *+host+ - the host from which to fetch the cert
    #
    # ==== Example
    # get_cert(master)
    def get_cert(host)
      if host.host_hash[:cert].class == OpenSSL::X509::Certificate
	return host.host_hash[:cert]
      else
        cert = encode_cert(host, host.puppet['hostcert'])
	host.host_hash[:cert] = cert
	return cert
      end
    end

    # Fetch the host's private key from the specified host and return it
    # as an OpenSSL::PKey::RSA object
    # ==== Attributes
    # *+host+ - the host from which to fetch the key
    #
    # ==== Example
    # get_key(master)
    def get_key(host)
      if host.host_hash[:key].class == OpenSSL::PKey::RSA
	return host.host_hash[:key]
      else
        key = encode_key(host, host.puppet['hostprivkey'])
        host.host_hash[:key] = key
	return key
      end
    end

    # Convert the contents of the certificate file in cert_file on the host
    # specified by cert_host into an X.509 certificate and return it
    # ==== Attributes
    # *+cert_host+ - The host whose cert you want
    # *+cert_file+ - The specific cert file you want
    # *+silent+ - Suppress beaker's output; set to false to see it
    #
    # ==== Examples
    # encode_cert(master, '/etc/ssl/private/host.cert')
    # encode_cert(master, '/etc/ssl/private/host.cert', false)
    def encode_cert(cert_host, cert_file, silent = true)
      rawcert = on(cert_host, "cat #{cert_file}", {:silent => silent}).stdout.strip
      OpenSSL::X509::Certificate.new(rawcert)
    end

    # Convert the contents of the private key file in key_file on the host
    # specified by key_host into an RSA private key and return it
    # ==== Attributes
    # *+key_host+ - The host whose key you want
    # *+key_file+ - The specific key file you want
    # *+silent+ - Suppress beaker's output; set to false to see it
    #
    # ==== Examples
    # encode_key(master, '/etc/ssl/private/host.key')
    # encode_key(agent, '/etc/ssl/private/host.key', :silent => false)
    def encode_key(key_host, key_file, silent = true)
      rawkey = on(key_host, "cat #{key_file}", {:silent => silent}).stdout.strip
      OpenSSL::PKey::RSA.new(rawkey)
    end

    # Issue an HTTP request and return the Net::HTTPResponse object. Lifted from
    # pe_acceptance_tests/2015.3.x/lib/http_calls.rb and slightly modified.
    # ==== Attributes
    # **url+ - (String) URL to poke
    # **method+ - (Symbol) :post, :get
    # **cert+ - (OpenSSL::X509::Certificate, String) The certificate to
    #       use for authentication.
    # **key+ - (OpenSSL::PKey::RSA, String) The private key to use for
    #      authentication
    # **body+ - (String) Request body (default empty)
    #
    # ==== Examples
    def https_request(url, request_method, cert, key, body = nil)
      # Make insecure https request
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)

      if cert.is_a?(OpenSSL::X509::Certificate)
        http.cert = cert
      else
        raise TypeError, 
          "cert must be an OpenSSL::X509::Certificate object, not #{cert.class}"
      end

      if key.is_a?(OpenSSL::PKey::RSA)
        http.key = key
      else
        raise TypeError,
        "key must be an OpenSSL::PKey:RSA object, not #{key.class}"
      end

      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      if request_method == :post
        request = Net::HTTP::Post.new(uri.request_uri)
        # Needs the content type even though no data is being sent
        request.content_type = 'application/json'
        request.body = body
      else
        request = Net::HTTP::Get.new(uri.request_uri)
      end
      response = http.request(request)
    end

    # Determine the version of PE installed on the master
    #
    # ==== Attributes
    # *+host+ - the host that this should operate on
    #
    # ==== Returns
    #
    # +string+ -The version of puppet enterprise, if version can not be determined 'version unknown' is returned
    #
    # ==== Examples
    #
    # pe_version
    def pe_version(host)
      if on(host, 'test -f /opt/puppet/pe_version', :acceptable_exit_codes => [0,1]).exit_code == 0
        return on(host, 'cat /opt/puppet/pe_version').stdout.chomp
      elsif on(host, 'test -f /opt/puppetlabs/server/pe_version', :acceptable_exit_codes => [0,1]).exit_code == 0
        return on(host, 'cat /opt/puppetlabs/server/pe_version').stdout.chomp
      else
        return 'version unknown'
      end
    end

  end
end
