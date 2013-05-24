#
# Cookbook Name:: fw1
# Recipe:: default
#
# Copyright 2013, Courtney Wilburn, Nathan Mische
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
 
# Install the unzip package
 
package "unzip" do
  action :install
end

node.set['fw1']['owner'] = node['cf10']['installer']['runtimeuser'] if node['fw1']['owner'] == nil

node['fw1']['fw1_versions'].each_with_index do |version, index|

  file_name = "#{version}.zip"
  zip_url = "#{node['fw1']['download_url_base']}/#{file_name}"
  dotless_name = version.gsub("\.","-")
   
  # Download FW1
   
  remote_file "#{Chef::Config['file_cache_path']}/#{file_name}" do
    source "#{zip_url}"
    action :create_if_missing
    mode "0744"
    owner "root"
    group "root"
    not_if { File.exists?("#{node['fw1']['install_path']}/#{dotless_name}/org/corfield/framework.cfc") }
  end

  # Create the target install directory if it doesn't exist
   
  directory "#{node['fw1']['install_path']}/#{dotless_name}/org/corfield" do
    owner node['fw1']['owner']
    group node['fw1']['group']
    mode "0755"
    action :create
    recursive true
    not_if { File.directory?("#{node['fw1']['install_path']}/#{dotless_name}/org/corfield") }
  end
   
  # Extract archive
   
  script "install_fw1_#{dotless_name}" do
    interpreter "bash"
    user "root"
    cwd "#{Chef::Config['file_cache_path']}"
    code <<-EOH
  unzip -j #{file_name} **framework.cfc -d #{node['fw1']['install_path']}/#{dotless_name}/org/corfield
  chown -R #{node['fw1']['owner']}:#{node['fw1']['group']} #{node['fw1']['install_path']}
  EOH
    not_if { File.exists?("#{node['fw1']['install_path']}/#{dotless_name}/org/corfield/framework.cfc") }
  end
   
  # Set up ColdFusion mapping
   
  execute "start_cf_for_fw1_#{dotless_name}_cf_config" do
    command "/bin/true"
    notifies :start, "service[coldfusion]", :immediately
  end
   
  coldfusion10_config "extensions" do
    action :set
    property "mapping"
    args ({ "mapName" => "#{node['fw1']['logical_paths'][index]}",
            "mapPath" => "#{node['fw1']['install_path']}/#{dotless_name}/org"})
  end

end