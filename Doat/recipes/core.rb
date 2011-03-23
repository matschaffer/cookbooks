include_recipe "Doat"
include_recipe "redis"
include_recipe "Doat::scribe-client"
include_recipe "python"

["Core", "common", "bin/#{node[:doat][:arch]}", "melt"].each do |component|
  doat_svn component
end

%w(python-crypto python-nltk python-mysqldb python-enchant).each do |pkg|
  package pkg
end

%w(PySQLPool redis hiredis).each do |pkg|
  easy_install_package pkg
end

redis_instance "melt" do
  data_dir "/var/lib/redis/melt"
  port 6378
end

redis_instance "search" do
  data_dir "/var/lib/redis/search"
  port 6379
end

directory "/opt/doat/data" do
  owner "doat"
  group "doat"
  mode "0755"
end

cookbook_file "/etc/init/cored.conf" do
  source "cored.upstart.conf"
end

cookbook_file "/etc/init/autocompleted.conf" do
  source "autocompleted.upstart.conf"
end

if node[:redis][:instances][:melt][:replication][:role] == "master"
  redis_melt_master = node
else
  redis_melt_master = provider_for_service(:redis_melt, :filters => {:replication => "master"})
end
app_config = data_bag_item(:doat_config, :core)
sql_host = search(:endpoints, "type:rds AND db:#{app_config["db"]}").first
sql_credentials = search(:credentials, "usage:db_#{app_config["db"]}").first

template "/etc/doat/core.conf" do
  source "core.conf.erb"
  variables :redis_melt_master => redis_melt_master, :redis_melt_slave => node, :redis_search_node => node,
    :sql_credentials => sql_credentials, :sql => sql_host, :autocomplete_node => node,
    :app_config => app_config
  notifies :restart, "service[cored]"
end

template "/etc/doat/autocomplete.conf" do
  source "autocomplete.conf.erb"
  notifies :restart, "service[autocompleted]"
end

service "autocompleted" do
  action [:start, :enable]
  supports :restart => false
  provider ::Chef::Provider::Service::Upstart
end

service "cored" do
  action [:start, :enable]
  provider ::Chef::Provider::Service::Upstart
end

if node[:doat][:core][:master]
  template "/etc/doat/synq.conf" do
    source "synqd.conf.erb"
    mode "0644"
    owner "doat"
    notifies :restart, "service[synqd]"
  end

  cookbook_file "/etc/init/synqd.conf" do
    source "synqd.upstart.conf"
  end

  service "synqd" do
    action [:start, :enable]
    supports :restart => false
    provider ::Chef::Provider::Service::Upstart
  end
end

provide_service(:core)
