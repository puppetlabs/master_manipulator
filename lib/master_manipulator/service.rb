module MasterManipulator
  module Service

    # Restart the puppet server and wait for it to come back up
    # ==== Attributes
    # *+host+ - the host that this should operate on
    # *+opts+ - an options hash - not required
    #   *+:timeout+ - the amount of time in seconds to wait for success
    #   *+:frequency+ - The time to wait between retries
    #   *+:is_pe?+ - Boolean : if the SUT is PE, defaults to true
    #
    # Raises a standard error if the wait is unsuccessful
    #
    # ==== Example
    # restart_puppet_server(master)
    # restart_puppet_server(master, {:time_out => 200, :frequency => 10})
    def restart_puppet_server(host, opts = {})

      opts[:is_pe?] ||= true
      opts[:is_pe?] ? service_name = 'pe-puppetserver' : service_name = 'puppetserver'

      on(host, puppet("resource service #{service_name} ensure=stopped"))
      on(host, puppet("resource service #{service_name} ensure=running"))
      masterHostName = on(host, 'hostname').stdout.chomp
      opts[:time_out] ||= 60
      opts[:frequency] ||= 5
      i = 0

      # -k to ignore HTTPS error that isn't relevant to us
      curl_call = "-I -k https://#{masterHostName}:8140"

      while i < opts[:time_out] do
        i += 1
        exit_code = curl_on(host, curl_call, :acceptable_exit_codes => [0,1,7]).exit_code
        case exit_code.to_s
          when '0'
            sleep 20
            return
          when '1' || '7'
            # Exit code 7 is "connection refused"
            sleep opts[:frequency]
        end
      end

      message = "Attempted to restart #{i} times, waited #{opts[:frequency]} seconds between attempts."
      raise message

    end

  end
end
