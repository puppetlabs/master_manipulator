module MasterManipulator
  module Site

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
    # site_pp = create_site_pp(master_host, '', node_def_name='agent')
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
      if (opts[:owner].nil?)
        owner = on(host, puppet('config print user')).stdout.rstrip
      end

      if (opts[:group].nil?)
        group = on(host, puppet('config print group')).stdout.rstrip
      end

      on(host, "chmod -R #{mode} #{path}")
      on(host, "chown -R #{owner}:#{group} #{path}")
    end

    # Inject temporary "site.pp" onto target host. This will also create
    # a "modules" folder in the target remote directory.
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

      set_perms_on_remote(master_host, site_pp_dir, "777")
    end

  end
end
