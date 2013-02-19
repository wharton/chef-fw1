#
# Cookbook Name:: fw1
# Recipe:: default
#
# Copyright 2012, Courtney Wilburn
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Create Directory if missing
 
# Install the unzip package
 
package "unzip" do
  action :install
end
 
fw1_version = node['fw1']['fw1_version']
 
case fw1_version
when "2"
  zip_url = node['fw1']['2']['download']['url']
when "1"
  zip_url = node['fw1']['1']['download']['url']
end
 
file_name = zip_url.split('/').last

node.set['fw1']['owner'] = node['cf10']['installer']['runtimeuser'] if node['fw1']['owner'] == nil
 
# Download FW1
 
remote_file "#{Chef::Config['file_cache_path']}/#{file_name}" do
  source "#{zip_url}"
  action :create_if_missing
  mode "0744"
  owner "root"
  group "root"
  not_if { File.exists?("#{node['fw1']['install_path']}/org/corfield/framework.cfc") }
end

# Create the target install directory if it doesn't exist
 
directory "#{node['fw1']['install_path']}/org/corfield" do
  owner node['fw1']['owner']
  group node['fw1']['group']
  mode "0755"
  action :create
  recursive true
  not_if { File.directory?("#{node['fw1']['install_path']}/org/corfield") }
end
 
# Extract archive
 
script "install_fw1" do
  interpreter "bash"
  user "root"
  cwd "#{Chef::Config['file_cache_path']}"
  code <<-EOH
unzip -j #{file_name} **framework.cfc -d #{node['fw1']['install_path']}/org/corfield
chown -R #{node['fw1']['owner']}:#{node['fw1']['group']} #{node['fw1']['install_path']}
EOH
  not_if { File.exists?("#{node['fw1']['install_path']}/org/corfield/framework.cfc") }
end
 
# Set up ColdFusion mapping
 
execute "start_cf_for_fw1_default_cf_config" do
  command "/bin/true"
  notifies :start, "service[coldfusion]", :immediately
end

coldfusion902_config "extensions" do
  action :set
  property "mapping"
  args ({ "mapName" => "#{node['fw1']['logical_path']}",
          "mapPath" => "#{node['fw1']['install_path']}/org"})
end