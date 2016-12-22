module MasterManipulator
  module Config

    # Disable the Node Classifier on the Puppet master
    # @param master_host [Beaker::Host] the master running Puppet Server.
    # @return Nothing
    # @example site_pp = disable_node_classifier(master_host)
    def disable_node_classifier(master_host)
      on(master_host, puppet('config set node_terminus plain --section master'))
    end

    # Disable environment caching on the Puppet master. Modifying this
    # this setting requires a reload or restart of puppetserver.
    # @param master_host [Beaker::Host] the master running puppetserver
    # @return Nothing
    # @example site_pp = disable_node_classifier(master_host)
    def disable_env_cache(master_host)
      on(master_host, puppet('config set environment_timeout 0 --section main'))
    end

  end
end
