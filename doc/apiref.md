# Master Manipulator API Summary, v1

Before trying to use the APIs described in this document, please
make sure you have installed the Master Manipulator gem as described
in the top-level [README.md](../README.md). As the name implies,
this document is a high-level description of each Master Manipulator
(_MM_ henceforth) API call, the method signature, and a simple
example. Read this if you are impatient and just want to start
slinging code. Complete documentation is maintained in YARD.

## Methods

### `disable_node_classifier(host)`

Disables the node classifier on a PE master and use the $PUPPETDIR/site.pp
manifest instead for node classification.

* Disable the node classifier on master:

    ```
    disable_node_classifier(master)
    ```

### `disable_env_cache(host)`

Disables environment caching on a PE master to allow dynamic updates
to environments without waiting for cache purge.

* Disable the environment cache master:

    ```
    disable_env_cache(master)
    ```

### `restart_puppet_server(host)`

Restarts the puppetserver service to pickup configuration changes
made to puppet.conf or other configuration files. *NOTE* This stops
and restarts puppetserver, which is a slow process compared to
simply _reloading_ puppetserver, which issues a HUP to the puppetserver
process to force reloading configuration files. See
[`reload_puppetserver`]().

* Restart puppetserver on the master:

    ```
    restart_puppet_server(master)
    ```

### `get_manifests_path(host)`

Returns the path to the manifests folder for an environment on a
master.

* Retrieve the path to the manifests folder for the production environment:

    ```
    prod_env_manifests_path = get_manifests_path(master)
    ```

* Retrieve the path to the manifests folder for the staging environment:

    ```
    stage_env_manifests_path = get_manifests_path(master, :env => 'staging')
    ```

### `get_site_pp_path(host)`

Returns the path to the site.pp manifest for an environment on a
master.
  
* Retrieve the path to the site.pp manifest for the production environment:

    ```
    prod_env_site_pp_path = get_site_pp_path(master)
    ```
* Retrieve the path to the site.pp manifest for the production environment.

    ```
    stage_env_site_pp_path = get_site_pp_path(master, :env => 'staging')
    ```

### `create_site_pp(host, manifest)`

Creates a site.pp file with file bucket enabled. Supports the
creation of a custom node definition or use the 'default' node
definition.

* Create a site.pp manifest with the default node definition using a simple manifest:

    ```
    site_pp = create_site_pp(master, :manifest => 'notify { hello: }')
    ```
* Create a site.pp manifest with a custom node definition using a simple manifest:

    ```
    site_pp = create_site_pp(master, :node_def_name => 'puppet_agent', :manifest => 'notify { hello: }')
    ```

### `set_perms_on_remote(host, path, mode)`

Sets permissions and ownership on a remote file.

* Set permissions on the site.pp manifest with default ownership of Puppet user and group.

    ```
    set_perms_on_remote(master, get_site_pp_path(master), '644')
    ```

* Set permissions on the site.pp manifest with root ownership:

    ```
    set_perms_on_remote(master, get_site_pp_path(master), '644', :owner => 'root', :group => 'root')
    ```
    
### `inject_site_pp(host, path, manifest)`

Injects a site.pp manifest onto a master.

* Inject a site.pp manifest onto master

    ```
    prod_env_site_pp_path = get_site_pp_path(master)
    site_pp = create_site_pp(master, :manifest => 'notify { hello: }')
    inject_site_pp(master, prod_env_site_pp_path, site_pp)
    ```
