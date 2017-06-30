# Master Manipulator API Summary, v1

Before trying to use the APIs described in this document, please
make sure you have installed the Master Manipulator gem as described
in the top-level [README.md](../README.md). As the name implies,
this document is a high-level description of each Master Manipulator
(_MM_ henceforth) API call, the method signature, and a simple
example. Read this if you are impatient and just want to start
slinging code. Complete documentation is maintained in YARD.

## Methods

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

### `inject_site_pp(host, path, manifest)`

Injects a site.pp manifest onto a master.

* Inject a site.pp manifest onto master

    ```
    prod_env_site_pp_path = get_site_pp_path(master)
    site_pp = create_site_pp(master, :manifest => 'notify { hello: }')
    inject_site_pp(master, prod_env_site_pp_path, site_pp)
    ```

### `pe_version(master)`

Returns the version of PE installed on the specified Puppet master as a string

* Return the version of PE running on master
    ```
    ver = pe_version(master)
    ```

### `reload_puppet_server(host)`

Reloads puppetserver to pick up changes made to puppet.conf and other 
configuration files. *NOTE* This call does not restart the JVM. Rather
it wraps the `puppetserver reload` subcommand and, as a result, is
considerable faster than `restart_puppet_server` and should be used in
place of it whenerver possible.

* Reload puppetserver on the master:
    ```
    reload_puppet_server(master)
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

### `puppet_server_log_path(host)`

Returns the location of the puppetserver log file.

* Return the path the puppetserver log file

    ```
    path = puppet_server_log_path(master)

    ```

### `rotate_puppet_server_log(host)`

Performs a log file rotation on the puppetserver log file.  
Intended to mimic what logback would do, which is a copy truncate.

* Rotate the puppetserver log file on the master:

    ```
    rotate_puppet_server_log(master)
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
    

