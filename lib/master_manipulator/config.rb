module MasterManipulator
  module Config

    # Disable the node classifier on the Puppet master
    # @param [Beaker::Host] master_host The master running the Puppet server.
    # @return nil
    # @example Disable the node classifier on the master
    #   disable_node_classifier(master)
    #   reload_puppetserver(master)
    def disable_node_classifier(master_host)
      on(master_host, puppet('config set node_terminus plain --section master'))
    end

    # Disable environment caching on the Puppet master. Modifying this
    # this setting requires reloading (preferred) or restarting (not
    # preferred) the Puppet server
    # @param [Beaker::Host] master_host The master running the Puppet server.
    # @return nil
    # @example Disable the environment cache on master
    #   disable_env_cache(master)
    #   reload_puppetserver(master)
    def disable_env_cache(master_host)
      on(master_host, puppet('config set environment_timeout 0 --section main'))
    end

  end
end
