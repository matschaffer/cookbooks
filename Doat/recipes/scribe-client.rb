include_recipe "Doat"
directory node[:scribe][:tmp_dir] do
  mode "0750"
  owner node[:scribe][:user]
  group node[:scribe][:group]
end

scribe = provider_for_service(:scribe)
Chef::Log.info scribe.inspect

directory node[:scribe][:conf_dir] do
  mode "0755"
end

conf_file = ::File.join(node[:scribe][:conf_dir], "scribe-client.conf")
template conf_file do
  source "scribe-client.conf.erb"
  variables :scribe => scribe
end

template "/etc/init/scribe-client.conf" do
  source "scribe.upstart.conf"
  variables :conf_file => conf_file
end

service "scribe-client" do
  action [:enable, :start]
  running true
  provider ::Chef::Provider::Service::Upstart
end
