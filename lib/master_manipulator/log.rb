
module MasterManipulator
  module Log

    # Return the path to the puppetserver log file
    # @param [Beaker::Host] master_host The puppet server host
    # @return [String] path to puppetserver log file
    # @example return the path to the puppet server log file
    #   puppet_server_log_path(master)
    def puppet_server_log_path(master_host)
      # we use the "puppet config print logdir" to build the path, because "puppet master --configprint logdir" is
      # set to the the puppet agent directory instead of the puppetserver, on some of the PE tests so we can't use it
      log_dir = on(master_host, puppet("config print logdir")).stdout.chomp
      "#{log_dir}server/puppetserver.log"
    end

    #<fileNamePattern>/var/log/puppetlabs/puppetserver/puppetserver-%d{yyyy-MM-dd}.%i.log.gz</fileNamePattern>

    # Rollover the puppetserver log file the same way logback would
    # @param [Beaker::Host] master_host The host to manipulate.
    # @return nil
    # @example Rollover the puppetserver log on a PE master
    #   rotate_puppet_server_log(master)
    def rotate_puppet_server_log(master_host)

      log_file = puppet_server_log_path(master_host)

      date_str = on(master_host, "date +%Y-%m-%d").stdout.chomp
      backup_log_file = log_file.sub(/\log$/,date_str)

      if ( on(master_host, "test -f #{log_file}",:accept_all_exit_codes => true).exit_code != 0 ) then
        raise("Puppetserver log file missing: #{log_file}")
      end

      i = 0
      max = 100
      while (i < max) do 
        if ( on(master_host, "test -f #{backup_log_file}.#{i}.log",:accept_all_exit_codes => true).exit_code == 1 ) then
          backup_log_file = "#{backup_log_file}.#{i}.log"
          break
        end
        i += 1
      end
      if ( i == max ) then
        raise("Looks like #{max} puppetserver log rotations in one minute, more likely a code issue")
      end
      if ( on(master_host, "cp #{log_file} #{backup_log_file}; cat /dev/null > #{log_file}",:accept_all_exit_codes => true).exit_code != 0 ) then
        raise("The copy truncate operation failed: cp #{log_file} #{backup_log_file}; cat /dev/null > #{log_file}");
      end

    end

  end
end

