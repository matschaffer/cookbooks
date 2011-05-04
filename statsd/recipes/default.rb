#
# Cookbook Name:: statsd
# Recipe:: default
#
# Copyright 2011, Fewbytes
#

package "statsd"

graphite_node = provider_for_service("graphite-carbon")
template "/etc/statsd/rdioConfig.js" do
  mode "0644"
  notifies :restart, "service[statsd]"
  variables :graphite_node => graphite_node
end

service "statsd" do
  provider Chef::Provider::Service::Upstart
  action [:start, :enable]
end
