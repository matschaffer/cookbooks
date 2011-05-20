#
# Cookbook Name:: elasticsearch
# Recipe:: default
#
# Copyright 2011, FewBytes technologies LTD
#
# All rights reserved 
#
require 'json'
include_recipe "java"
[ node[:elasticsearch][:conf_dir], node[:elasticsearch][:inst_dir] ].each do |dir|
  directory dir do
    mode "0755"
  end
end

user node[:elasticsearch][:user] do
  system true
end

[ node[:elasticsearch][:es][:path][:data],
  node[:elasticsearch][:es][:path][:logs],
  node[:elasticsearch][:pid_dir] ].each do |dir|
  directory dir do
    owner node[:elasticsearch][:user]
    mode "0755"
  end
end

bash "Install elastic search" do
  code <<-EOH
set -e
wget --no-check-certificate -O elasticsearch.tar.gz #{node[:elasticsearch][:tarball_url]}
tar -xzf elasticsearch.tar.gz
ES_DIR=$(ls -1d elasticsearch-*)
[ -z "$ES_DIR" ] && exit 1
mv $ES_DIR/* #{node[:elasticsearch][:inst_dir]}/
EOH
  cwd "/tmp"
  not_if { ::File.exists? "#{node[:elasticsearch][:inst_dir]}/bin/elasticsearch" }
end

es_hosts = search("recipe:elasticsearch AND elasticsearch_es_cluster_name:#{node[:elasticsearch][:es][:cluster][:name]}").map do |n|
  n[:ipaddress]
end
file ::File.join(node[:elasticsearch][:conf_dir], "elasticsearch.json") do
  content JSON.pretty_generate(node[:elasticsearch][:es].to_hash.merge(:hosts => es_hosts))
  mode "0644"
  notifies :restart, "service[elasticsearch]"
end

init_config_file = value_for_platform(:default => "/etc/default/elasticsearch",
                                      [:centos, :redhat, :fedora] => {:default => "/etc/sysconfig/elasticsearch"})
template init_config_file do
  source "elasticsearch.default.erb"
  notifies :restart, "service[elasticsearch]"
end

case node[:elasticsearch][:init_style]
when "upstart"
  init_script = "/etc/init/elasticsearch.conf"
  init_script_template = "elasticsearch.upstart.conf.erb"
  init_mode = "0644"
when "runit"
  include_recipe "runit"
  runit_service "elasticsearch" do
    template_name "elasticsearch"
    cookbook "elasticsearch"
    options :user => node[:elasticsearch][:user], :defaults_file => init_config_file
  end
when "init"
  init_script = "/etc/init.d/elasticsearch"
  init_script_template = "elasticsearch.init.erb"
  init_mode = "0755"
end

if init_script
  template init_script do
    source init_script_template
    variables :init_config_file => init_config_file
    mode init_mode
  end

  service "elasticsearch" do
    action [:enable, :start]
    provider ::Chef::Provider::Service::Upstart if node[:elasticsearch][:init_style] == "upstart"
  end
end

