Description
===========

Installs the FW1 framework for ColdFusion.

Requirements
============

Cookbooks
---------

coldfusion902

Attributes
==========

* `node['fw1']['install_path']` (Default is "/vagrant/frameworks")
* `node['fw1']['logical_path']` (Default is "/org")
* `node['fw1']['fw1_version']` (Default is '2')
* `node['fw1']['2']['download']['url']` (Default is "https://github.com/seancorfield/fw1/archive/2.0.1.zip")
* `node['fw1']['1']['download']['url']` (Default is "https://github.com/seancorfield/fw1/archive/v1.2.2.zip")

Usage
=====

On ColdFusion server nodes:

    include_recipe "fw1"

In your Application.cfc:
	add extends="org.corfield.framework" where org is the logical mapping defined above

