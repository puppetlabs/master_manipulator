module MasterManipulator
  module Site

    # Get the location of an environment's manifests path; defaults to production environment.
    # @param [Beaker::Host] master_host The master host that contains environments
    # @param [Hash] opts:env The environment from which to discover the manifests path
    # @return [String] An absolute path to the manifests for an environment on the master host
    # @example prod_env_manifests_path = get_manifests_path(master)
    def get_manifests_path(master_host, opts = {})
      opts[:env] ||= 'production'
      environment_base_path = on(master_host, puppet('config print environmentpath')).stdout.rstrip

      return File.join(environment_base_path, opts[:env], 'manifests')
    end

    # Get the location of an environment's site.pp path. Defaults to production environment
    # @param [Beaker::Host] master_host The master host that contains environments
    # @param [Hash] opts:env The environment from which to discover the site.pp path
    # @return [String] An absolute path to the site.pp for an environment on the master host
    # @example prod_env_site_pp_path = get_site_pp_path(master)
    def get_site_pp_path(master_host, opts = {})
      opts[:env] ||= 'production'

      return File.join(get_manifests_path(master_host, opts), 'site.pp')
    end

    # Create a "site.pp" file with file bucket enabled. Also, allow
    # the creation of a custom node definition or use the default
    # node definition.
    # @param [Beaker::Host] master_host the target master for "site.pp" injection
    # @param [Hash] opts:manifest a Puppet manifest to inject into the node definition
    # @param [Hash] opts:node_def_name a node definition pattern or name
    # @return [String] manifest a combined manifest with node definition containing input manifest
    # @example site_pp = create_site_pp(master, '', node_def_name='agent')
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
    # @param [Beaker::Host] host the remote host containing the target path.
    # @param [String] path the path to set mode, user and group upon.
    # @param [String] mode the desired mode to set on the path in as a string.
    # @param [Hash] opts:owner the owner to set on the path; defaults to puppet user
    # @param [Hash] opts:group the group to set on the path; defulats to puppet group
    # @return nil
    # @example set_perms_on_remote(master, "/tmp/test/site.pp", "777")
    def set_perms_on_remote(host, path, mode, opts = {})
      opts[:owner] ||= on(host, puppet('config print user')).stdout.rstrip
      opts[:group] ||= on(host, puppet('config print group')).stdout.rstrip

      on(host, "chmod -R #{mode} #{path}")
      on(host, "chown -R #{opts[:owner]}:#{opts[:group]} #{path}")
    end

    # Inject a "site.pp" manifest onto a master.
    # @param [Beaker::Host] master_host the target master for injection.
    # @param [String] site_pp_path a path on the remote host into which the site.pp will be injected.
    # @param [String] manifest the manifest content to inject into "site.pp" to the host target path.
    # @return nil
    # @example site_pp = inject_site_pp(master_host, "/tmp/test/site.pp", manifest)
    def inject_site_pp(master_host, site_pp_path, manifest)
      site_pp_dir = File.dirname(site_pp_path)
      create_remote_file(master_host, site_pp_path, manifest)

      set_perms_on_remote(master_host, site_pp_dir, '744')
    end

  end
end
