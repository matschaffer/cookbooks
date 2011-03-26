include_recipe "Doat"
package "libboost-system1.40.0"
package "libboost-filesystem1.40.0"
package "libevent-1.4-2"

doat_svn "bin/#{node[:doat][:arch]}"

group node[:scribe][:group]

user node[:scribe][:user] do
  system true
  group node[:scribe][:group]
end

directory node[:scribe][:tmp_dir] do
  mode "0750"
  owner node[:scribe][:user]
  group node[:scribe][:group]
end

scribe = provider_for_service(:scribe)

directory node[:scribe][:conf_dir] do
  mode "0755"
end

conf_file = ::File.join(node[:scribe][:conf_dir], "scribe-client.conf")
template conf_file do
  source "scribe-client.conf.erb"
  variables :scribe => scribe
  owner node[:scribe][:user]
  mode "0644"
end

template "/etc/init/scribe-client.conf" do
  source "scribe.upstart.conf.erb"
  variables :conf_file => conf_file
end

service "scribe-client" do
  action :enable
  provider ::Chef::Provider::Service::Upstart
end
