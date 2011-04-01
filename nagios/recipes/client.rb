#
# Author:: Joshua Sierles <joshua@37signals.com>
# Author:: Joshua Timberman <joshua@opscode.com>
# Author:: Nathan Haneysmith <nathan@opscode.com>
# Cookbook Name:: nagios
# Recipe:: client
#
# Copyright 2009, 37signals
# Copyright 2009-2010, Opscode, Inc
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

include_recipe "sudo"
mon_host = Array.new

if node.run_list.roles.include?(node[:nagios][:server_role])
  mon_host << node[:ipaddress]
else
  all_providers_for_service("monitoring").each do |n|
    mon_host << n['ipaddress']
  end
end
if node.nagios.attribute? :external_monitors
  mon_host += node[:nagios][:external_monitors]
end
Chef::Log.info "NRPE server whitelisted monitors: #{mon_host.join(", ")}"

gem_package "choice"

%w{
  nagios-nrpe-server
  nagios-plugins
  nagios-plugins-basic
  nagios-plugins-standard
}.each do |pkg|
  package pkg
end

service "nagios-nrpe-server" do
  action [:enable, :start]
  supports :restart => true, :reload => true
end

remote_directory "/usr/lib/nagios/plugins" do
  source "plugins"
  owner "nagios"
  group "nagios"
  mode 0755
  files_mode 0755
end

template "/etc/nagios/nrpe.cfg" do
  source "nrpe.cfg.erb"
  owner "nagios"
  group "nagios"
  mode "0644"
  variables :mon_host => mon_host
  notifies :restart, resources(:service => "nagios-nrpe-server")
end

ruby_block "nagios-monitored" do
  block do
    node[:nagios][:monitored] = true
  end
end
