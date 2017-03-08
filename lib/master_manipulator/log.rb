
module MasterManipulator
  module Log

    #<fileNamePattern>/var/log/puppetlabs/puppetserver/puppetserver-%d{yyyy-MM-dd}.%i.log.gz</fileNamePattern>

    # Rollover the puppetserver log file the same way logback would
    # @param [Beaker::Host] master_host The host to manipulate.
    # @return nil
    # @example Rollover the puppetserver log on a PE master
    #   rotate_puppet_server_log(master)
    def rotate_puppet_server_log(master_host)

      log_dir = on(master_host, "puppet config print logdir").stdout.chomp
      #this is ugly, rev 2 should parse the logback.xml, doesn't seem to be another way
      log_file = log_dir + "server/puppetserver.log"

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

