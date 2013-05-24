Description
===========

Installs the FW1 framework for ColdFusion.

Requirements
============

Cookbooks
---------

coldfusion10

Attributes
==========

* `node['fw1']['install_path']` - The root directory to install FW/1 versions. Each version will have a sub directory under this directory. (Default is "/vagrant/frameworks/fw1")
* `node['fw1']['owner']` - The owner of the `install_path`. (Default is `nil` which will result in owner being set to `node['cf10']['installer']['runtimeuser']`)
* `node['fw1']['group']` - The group of the `install_path`. (Default is "bin")
* `node['fw1']['logical_paths']` - Array of mappings to be applied for each version of FW/1. There should be one key for each `fw1_versions` key.  (Default is ["/org"])
* `node['fw1']['fw1_versions']` - Array of framework versions to install. Each key should match a tag name in the [fw1 repository]( https://github.com/framework-one/fw1). (Default is ["v2.1.1"])
* `node['fw1']['download_url_base']` - The base URL for version downloads. (Default is "https://github.com/framework-one/fw1/archive")


Usage
=====

On ColdFusion server nodes:

    include_recipe "fw1"

In your Application.cfc:
	add extends="org.corfield.framework" where org is the logical mapping defined above

