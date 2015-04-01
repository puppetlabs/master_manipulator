module MasterManipulator
  module Config
    extend Beaker::DSL

    # Disable the Node Classifier on the Puppet master.
    # (Note: this requires a restart of Puppet Server to take affect.)
    # ==== Attributes
    #
    # * +master_host+ - The master running Puppet Server.
    #
    # ==== Returns
    #
    # nil
    #
    # ==== Examples
    #
    # site_pp = disable_node_classifier(master_host)
    def self.disable_node_classifier(master_host)
      on(master_host, puppet('config set node_terminus plain --section master'))
    end

    # Disable environment caching on the Puppet master.
    # (Note: this requires a restart of Puppet Server to take affect.)
    # ==== Attributes
    #
    # * +master_host+ - The master running Puppet Server.
    #
    # ==== Returns
    #
    # nil
    #
    # ==== Examples
    #
    # site_pp = disable_node_classifier(master_host)
    def self.disable_env_cache(master_host)
      on(master_host, puppet('config set environment_timeout 0 --section main'))
    end

  end
end
