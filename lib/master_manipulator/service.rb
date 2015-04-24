module MasterManipulator
  module Service

    # Restart the puppet server and wait for it to come back up
    # ==== Attributes
    # *+host+ - the host that this should operate on
    # *+opts+ - an options hash - not required
    #   *+:timeout+ - the amount of time in seconds to wait for success
    #   *+:frequency+ - The time to wait between retries
    #
    # Raises a standard error if the wait is unsuccessful
    #
    # ==== Example
    # restart_puppet_server(master)
    # restart_puppet_server(master, {:time_out => 200, :frequency => 10})
    def restart_puppet_server(host, opts = {})

      on(host, puppet('resource service pe-puppetserver ensure=stopped'))
      on(host, puppet('resource service pe-puppetserver ensure=running'))
      masterHostName = on(host, 'hostname').stdout.chomp
      opts[:time_out] ||= 100
      opts[:frequency] ||= 5
      i = 0

      # -k to ignore HTTPS error that isn't relevant to us
      curl_call = "-I -k https://#{masterHostName}:8140/production/certificate_statuses/all"

      while i < opts[:time_out] do
        sleep opts[:frequency]
        i += 1
        exit_code = curl_on(host, curl_call, :acceptable_exit_codes => [0,1,7]).exit_code

        # Exit code 7 is "connection refused"
        if exit_code != '7'
          sleep 20
          puts 'Restarting the Puppet Server was successful!'
          return
        end
      end

      raise StandardError, 'Attempting to restart the puppet server was not successful in the time alloted.'

    end

  end
end
