module MasterManipulator
  module Site

    # Get the location of an environment's manifests path; defaults to production environment.
    # @param [Beaker::Host] master_host The master host that contains environments.
    # @param [Hash] opts Optional options hash containing options.
    # @option opts [String] :env The environment to query on the specified master
    # @return [String] The absolute path to the manifests for the given environment on the given master
    # @example Get the manifests path for the production environment on master
    #   prod_env_manifests_path = get_manifests_path(master)
    # @example Get the manifests path for the testing environment on master
    #   test_env_manifests_path = get_manifests_path(master, {:env => 'test'})
    def get_manifests_path(master_host, opts = {:env => 'production'})
      environment_base_path = on(master_host, puppet('config print environmentpath')).stdout.rstrip

      return File.join(environment_base_path, opts[:env], 'manifests')
    end

    # Get the path to a given environment's site.pp; defaults to production environment.
    # @param [Beaker::Host] master_host The master to query.
    # @param [Hash] opts Optional options hash containing options.
    # @option opts [String] :env opts The environment to query on the specified master
    # @return [String] The absolute path to the site.pp for the given environment on the given master
    # @example Return the path to the site.pp file for the production environment on master
    #   prod_env_site_pp_path = get_site_pp_path(master)
    # @example Return the path to the site.pp file for the testing environment on master
    #   prod_env_site_pp_path = get_site_pp_path(master, {:env => 'testing'})
    def get_site_pp_path(master_host, opts = {:env => 'production'})

      return File.join(get_manifests_path(master_host, opts), 'site.pp')
    end

    # Create a site.pp file with file bucket enabled. Also, allow
    # the creation of a custom node definition or use the default
    # node definition.
    # @param [Beaker::Host] master_host the target master for site.pp injection.
    # @param [Hash] opts Optional options hash containing options.
    # @option opts [String] :manifest The node definition to lay down
    # @option opts [String] :node_def_name The node definition name
    # @return [String] manifest A manifest containing the input node definition to lay down in site.pp
    # @example Create a site.pp on master using the default node definition and an otherwise empty manifest
    #   site_pp = create_site_pp(master)
    # @example Create a site.pp on master for a node named 'mailgrunt' with an otherwise empty manifest
    #   site_pp = create_site_pp(master, {:node_def_name => 'mailgrunt'})
    # @example Create a site.pp on master for a node named 'mailgrunt' with a custom node definition in the manifest
    #   site_pp = create_site_pp(master, {:manifest => manifest_for_mailgrunt, :node_def_name => 'mailgrunt'})
    def create_site_pp(master_host, opts = {:manifest => '', :node_def_name => 'default'})
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
    # @param [Beaker::Host] master_host The remote host containing the target path.
    # @param [String] path The pathname on which to set mode, user and group.
    # @param [String] mode The desired file mode in 4-digit octal string (e.g. '0644').
    # @param [Hash] opts Optional options hash containing options.
    # @option opts [String] :owner The user owner to assign
    # @option opts [String] :group The group owner to assign
    # @return nil
    # @example Set perms on a file on master with the default user and group
    #   set_perms_on_remote(master, '/tmp/this_is_junk.pp', '0644')
    # @example Set perms on a file on master with the default user and a custom group
    #   set_perms_on_remote(master, '/tmp/this_is_junk.pp', '0644', {:group => 'tutones')
    # @example Set perms on a file on master with a custom user and the default group
    #   set_perms_on_remote(master, '/tmp/this_is_junk.pp', '0644', {:user => 'tommy')
    # @example Set perms on a file on master with a custom user and a custom group
    #   set_perms_on_remote(master, '/tmp/this_is_junk.pp', '0644', {:user => 'tommy', :group => 'tutones')
    def set_perms_on_remote(master_host, path, mode, opts = {:owner => 'puppet', :group => 'puppet'})
      opts[:owner] ||= on(master_host, puppet('config print user')).stdout.rstrip
      opts[:group] ||= on(master_host, puppet('config print group')).stdout.rstrip

      on(master_host, "chmod -Rv #{mode} #{path}")
      on(master_host, "chown -Rv #{opts[:owner]}:#{opts[:group]} #{path}")
    end

    # Inject a site.pp manifest onto a master.
    # @param [Beaker::Host] master_host the target master for injection.
    # @param [String] site_pp_path a path on the remote host into which the site.pp will be injected.
    # @param [String] manifest the manifest content to inject into site.pp to the host target path.
    # @return nil
    # @example Place this_is_junk.pp, with the contents defined in manifest, in /tmp on the master named compile_master
    #   site_pp = inject_site_pp(compile_master, '/tmp/this_is_junk.pp', manifest)
    def inject_site_pp(master_host, site_pp_path, manifest)
      site_pp_dir = File.dirname(site_pp_path)
      create_remote_file(master_host, site_pp_path, manifest)

      set_perms_on_remote(master_host, site_pp_dir, '0744')
    end

  end
end
