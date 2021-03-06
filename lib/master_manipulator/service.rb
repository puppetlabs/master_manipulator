require 'json'

module MasterManipulator
  module Service

    # Reload puppetserver, causing it to reread its config without
    # restarting the JVM. use this instead of restart_puppet_server 
    # unless you absolutely have to stop and restart the server because
    # JVM restarts are very expensive. This implementation relies on
    # puppetserver's "reload" subcommand, which handles all the waiting
    # for services to refresh. Older code using a forced HUP on the
    # server process should be replaced with this.
    # @param [Beaker::Host] master_host The host to manipulate.
    # @param [Hash] opts Optional options hash containing options
    # @return nil
    # @example Restart the puppetserver process on a PE or FOSS master
    #   restart_puppet_server(master)
    def reload_puppet_server(master_host, opts = {})
      # 2015.x (Everett) and newer
      rc = on(master_host, "puppetserver reload", :accept_all_exit_codes => true)
      if rc.exit_code != 0
        raise "'puppetserver reload' failed, returned: #{rc.exit_code}"
      end
    end

    # Restart the puppet server and wait for it to come back up or raise
    # an error if the wait times out
    # @param [Beaker::Host] master_host The host to manipulate.
    # @param [Hash] opts Optional options hash containing options
    # @option opts [Boolean] :is_pe? true if host is running PE, false otherwise
    # @option opts [Integer] :wait_cycles How many attempt to make before failing
    # @return nil
    # @example Restart the puppetserver process on a PE master
    #   restart_puppet_server(master)
    # @example Restart the puppetserver process on a FOSS master
    #   restart_puppet_server(master, {:is_pe? => false})
    # @example Restart the puppetserver process on a PE master, timing out after 20 attempts
    #   restart_puppet_server(master, {:wait_cycles => 20})
    # @example Restart the puppetserver process on a FOSS master, timing out after 20 attempts
    #   restart_puppet_server(master, {:is_pe? => false, :wait_cycles => 20})
    def restart_puppet_server(master_host, opts = {})

      start_time = Time.now

      opts[:is_pe?] ||= true
      opts[:is_pe?] ? service_name = 'pe-puppetserver' : service_name = 'puppetserver'

      on(master_host, puppet("resource service #{service_name} ensure=stopped"))
      on(master_host, puppet("resource service #{service_name} ensure=running"))
      hostname = on(master_host, 'hostname').stdout.chomp
      opts[:wait_cycles] ||= 10

      pe_ver = pe_version(master_host)
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
        @result = curl_on(master_host, curl_call, :acceptable_exit_codes => [0,1,7])
        # parse body if we are using PE and we are not in PE 3.8
        (pe_ver && !pe_ver.match(three_eight_regex)) ? @body = JSON.parse(@result.stdout) : @body = []

        case @result.exit_code.to_s
          when '0'
            sleep 20
            pe_ver.match(/three_eight_regex/) ? return : (return if @body.all? { |k, v| v['state'] == 'running' })
          when '1', '7'
            # Exit code 7 is 'connection refused'
            sleep (i**(1.2))
        end
      end

      total_time = Time.now - start_time
      message = "Attempted to restart #{opts[:wait_cycles]} times, waited #{total_time} seconds total."
      message << "\nHere is the status reported by the puppetserver"

      @body.each do |k,v|
        message << "\n'#{k}' state: #{v['state']} "
      end
      raise message

    end

    # Return the version of PE installed on the specified Puppet master
    # @param [Beaker::Host] master_host the master to query.
    # @return [String] The version of Puppet Enterprise, or 'version unknown' if undetermined
    # @example Return the version of PE running on master
    #   ver = pe_version(master)
    def pe_version(master_host)
      if on(master_host, 'test -f /opt/puppet/pe_version', :acceptable_exit_codes => [0,1]).exit_code == 0
        return on(master_host, 'cat /opt/puppet/pe_version').stdout.chomp
      elsif on(master_host, 'test -f /opt/puppetlabs/server/pe_version', :acceptable_exit_codes => [0,1]).exit_code == 0
        return on(master_host, 'cat /opt/puppetlabs/server/pe_version').stdout.chomp
      else
        return 'version unknown'
      end
    end

  end
end
