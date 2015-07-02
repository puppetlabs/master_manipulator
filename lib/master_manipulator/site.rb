module MasterManipulator
  module Site

    # Get the location of an environment's manifests path. (Defaults to "production" environment.)
    #
    # ==== Attributes
    #
    # * +master_host+ - The master host that contains environments.
    # * +opts:env+ - The environment from which to discover the manifests path.
    #
    # ==== Returns
    #
    # +string+ - An absolute path to the manifests for an environment on the master host.
    #
    # ==== Examples
    #
    # prod_env_manifests_path = get_manifests_path(master)
    def get_manifests_path(master_host, opts = {})
      opts[:env] ||= 'production'

      environment_base_path = on(master_host, puppet('config print environmentpath')).stdout.rstrip

      return File.join(environment_base_path, opts[:env], 'manifests')
    end

    # Get the location of an environment's "site.pp" path. (Defaults to "production" environment.)
    #
    # ==== Attributes
    #
    # * +master_host+ - The master host that contains environments.
    # * +opts:env+ - The environment from which to discover the "site.pp" path.
    #
    # ==== Returns
    #
    # +string+ - An absolute path to the "site.pp" for an environment on the master host.
    #
    # ==== Examples
    #
    # prod_env_site_pp_path = get_site_pp_path(master)
    def get_site_pp_path(master_host, opts = {})
      opts[:env] ||= 'production'

      return File.join(get_manifests_path(master_host, opts), 'site.pp')
    end

    # Create a "site.pp" file with file bucket enabled. Also, allow
    # the creation of a custom node definition or use the 'default'
    # node definition.
    #
    # ==== Attributes
    #
    # * +master_host+ - The target master for "site.pp" injection.
    # * +opts:manifest+ - A Puppet manifest to inject into the node definition.
    # * +opts:node_def_name+ - A node definition pattern or name.
    #
    # ==== Returns
    #
    # +string+ - A combined manifest with node definition containing input manifest
    #
    # ==== Examples
    #
    # site_pp = create_site_pp(master, '', node_def_name='agent')
    def create_site_pp(master_host, opts = {})
      opts[:manifest] ||= ''
      opts[:node_def_name] ||= 'default'
      master_certname = on(master_host, puppet('config print certname')).stdout.rstrip

      default_def = <<-MANIFEST
node default {
}
MANIFEST

      node_def = <<-MANIFEST
node #{opts[:node_def_name]} {

#{opts[:manifest]}
}
MANIFEST

      if opts[:node_def_name] != 'default'
        node_def = "#{default_def}\n#{node_def}"
      end

      site_pp = <<-MANIFEST
filebucket { 'main':
  server => '#{master_certname}',
  path   => false,
}

File { backup => 'main' }

#{node_def}
MANIFEST

      return site_pp
    end

    # Set mode, owner and group on a remote path.
    #
    # ==== Attributes
    #
    # * +host+ - The remote host containing the target path.
    # * +path+ - The path to set mode, user and group upon.
    # * +mode+ - The desired mode to set on the path in as a string.
    # * +opts:owner+ - The owner to set on the path. (Puppet user if not specified.)
    # * +opts:group+ - The group to set on the path. (Puppet group if not specified.)
    #
    # ==== Returns
    #
    # nil
    #
    # ==== Examples
    #
    # set_perms_on_remote(master, "/tmp/test/site.pp", "777")
    def set_perms_on_remote(host, path, mode, opts = {})
      opts[:owner] ||= on(host, puppet('config print user')).stdout.rstrip
      opts[:group] ||= on(host, puppet('config print group')).stdout.rstrip

      on(host, "chmod -R #{mode} #{path}")
      on(host, "chown -R #{opts[:owner]}:#{opts[:group]} #{path}")
    end

    # Inject a "site.pp" manifest onto a master.
    #
    # ==== Attributes
    #
    # * +master_host+ - The target master for injection.
    # * +site_pp_path+ - A path on the remote host into which the site.pp will be injected.
    # * +manifest+ - The manifest content to inject into "site.pp" to the host target path.
    #
    # ==== Returns
    #
    # nil
    #
    # ==== Examples
    #
    # site_pp = inject_site_pp(master_host, "/tmp/test/site.pp", manifest)
    def inject_site_pp(master_host, site_pp_path, manifest)
      site_pp_dir = File.dirname(site_pp_path)
      create_remote_file(master_host, site_pp_path, manifest)

      set_perms_on_remote(master_host, site_pp_dir, '744')
    end

  end
end
