# Master Manipulator

This Gem extends the Beaker DSL for the purpose of changing things on a
Puppet Master.

## Installation

Add this line to your application's Gemfile:

    gem 'master_manipulator'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install master_manipulator

## Methods

### disable_node_classifier

Disable the node classifier on a Puppet Enterprise master and use the "site.pp"
manifest instead for node classification.

#### Example

    disable_node_classifier(master)

### disable_env_cache

Disable environment caching on a Puppet Enterprise master to allow for dynamic
updates to environments without waiting for cache purge.

#### Example

    disable_env_cache(master)

### restart_puppet_server

Restart the Puppet Server service to pickup configuration changes made to the
"puppet.conf" file.

#### Example

Restart the Puppet Server service on Puppet Enterprise:

    restart_puppet_server(master)

### get_manifests_path

Retrieve the path to the manifests folder for an environment on a master.

#### Example 1

Retrieve the path to the manifests folder for the "production" environment.

    prod_env_manifests_path = get_manifests_path(master)

#### Example 2

Retrieve the path to the manifests folder for the "staging" environment.

    stage_env_manifests_path = get_manifests_path(master, :env => 'staging')

### get_site_pp_path

Retrieve the path to the "site.pp" manifest for an environment on a master.

#### Example 1

Retrieve the path to the "site.pp" manifest for the "production" environment.

    prod_env_site_pp_path = get_site_pp_path(master)

#### Example 2

Retrieve the path to the "site.pp" manifest for the "production" environment.

    stage_env_site_pp_path = get_site_pp_path(master, :env => 'staging')

### create_site_pp

Create a "site.pp" file with file bucket enabled. Also, allow the creation of a
custom node definition or use the 'default' node definition.

#### Example 1

Create a "site.pp" manifest with the default node definition using a simple
manifest.

    site_pp = create_site_pp(master, :manifest => 'notify { hello: }')

#### Example 2

Create a "site.pp" manifest with a custom node definition using a simple
manifest.

    site_pp = create_site_pp(master, :node_def_name => 'puppet_agent', :manifest => 'notify { hello: }')

### set_perms_on_remote

Set permissions and ownership on a remote file.

#### Example 1

Set permissions on the "site.pp" manifest with default ownership of Pupppet
user and group.

    set_perms_on_remote(master, get_site_pp_path(master), '644')

#### Example 2

Set permissions on the "site.pp" manifest with root ownership.

    set_perms_on_remote(master, get_site_pp_path(master), '644', :owner => 'root', :group => 'root')

### inject_site_pp

Inject a "site.pp" manifest onto a master.

#### Example

    prod_env_site_pp_path = get_site_pp_path(master)
    site_pp = create_site_pp(master, :manifest => 'notify { hello: }')
    inject_site_pp(master, prod_env_site_pp_path, site_pp)
