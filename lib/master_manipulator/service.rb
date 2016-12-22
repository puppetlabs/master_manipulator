require 'json'

module MasterManipulator
  module Service

    # Restart the puppet server and wait for it to come back up.
    # Raises a standard error if the wait is unsuccessful
    # ==== Attributes
    # @param [Beaker::Host] host the host that this should operate on
    # @param [Hash] opts an optional options hash
    #   *+:wait_cycles+ - the number of cycles to attempt retry
    #   *+:is_pe?+ - Boolean : if the SUT is PE, defaults to true
    # @return Nothing
    # @example restart_puppet_server(master)
    # @example restart_puppet_server(master, {:wait_cycles => 20})
    def restart_puppet_server(host, opts = {})

      start_time = Time.now

      opts[:is_pe?] ||= true
      opts[:is_pe?] ? service_name = 'pe-puppetserver' : service_name = 'puppetserver'

      on(host, puppet("resource service #{service_name} ensure=stopped"))
      on(host, puppet("resource service #{service_name} ensure=running"))
      hostname = on(host, 'hostname').stdout.chomp
      opts[:wait_cycles] ||= 10

      pe_ver = pe_version(host)
      three_eight_regex = /^3\.8/

      # This logic is not ideal refactor in the future
      # if its PE and not 3.8 use the status endpoint
      # it its not PE or it is 3.8 use the simple curl call
      if pe_ver && !pe_ver.match(three_eight_regex)
        curl_call = "-k -X GET -H 'Content-Type: application/json' https://#{hostname}:8140/status/v1/services?level=debug"
      else
        curl_call = "-I -k https://#{hostname}:8140"
      end

      (1..opts[:wait_cycles]).each do |i|
        @result = curl_on(host, curl_call, :acceptable_exit_codes => [0,1,7])
        # parse body if we are using PE and we are not in PE 3.8
        (pe_ver && !pe_ver.match(three_eight_regex)) ? @body = JSON.parse(@result.stdout) : @body = []

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
      message = "Attempted to restart #{opts[:wait_cycles]} times, waited #{total_time} seconds total."
      message << "\nHere is the status reported by the puppetserver'"

      @body.each do |k,v|
        message << "\n'#{k}' state: #{v['state']} "
      end
      raise message

    end

    # Determine the version of PE installed on the master
    # @param [Beaker::Host] host the host that this should operate on
    # @return [String] the version of puppet enterprise, if version can not be determined 'version unknown' is returned
    # ver = pe_version
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
