include_recipe "Doat"
include_recipe "redis"
include_recipe "Doat::scribe-client"
include_recipe "python"
include_recipe "aws"

doat_svn "bin/#{node[:doat][:arch]}"

%w(python-crypto python-nltk python-mysqldb python-enchant).each do |pkg|
  package pkg
end

%w(PySQLPool redis hiredis geohasher python-geohash).each do |pkg|
  easy_install_package pkg
end

redis_melt_master = provider_for_service("redis_melt", :service_filters => {:replication => "master"}) \
  if node[:redis][:instances][:melt][:replication][:role] == "slave"
redis_instance "melt" do
  data_dir "/var/lib/redis/melt"
  port 6378
  master redis_melt_master if node[:redis][:instances][:melt][:replication][:role] == "slave"
end

filters = {:replication => "master"}
filters[:replication_level] = 0 if node[:doat][:core][:type] == "master"
master_node = provider_for_service("redis_search", :service_filters => filters )
redis_instance "search" do
  data_dir "/var/lib/redis/search"
  port 6379
  master master_node
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
end
redis_geodis_node = provider_for_service(:redis_geodis)
app_config = data_bag_item(:doat_config, :core)
sql_host = search(:endpoints, "type:rds AND db:#{app_config["db"]}").first
sql_credentials = search(:credentials, "usage:db_#{app_config["db"]}").first

template "/etc/doat/core.conf" do
  source "core.conf.erb"
  variables :redis_melt_master => redis_melt_master, :redis_melt_slave => node, :redis_search_node => node,
    :sql_credentials => sql_credentials, :sql => sql_host, :autocomplete_node => node,
    :app_config => app_config, :redis_geodis_node => redis_geodis_node
  notifies :restart, "service[cored]", :immediately
  mode "0644"
end

doat_module "core"

template "/etc/doat/autocomplete.conf" do
  source "autocomplete.conf.erb"
  notifies :restart, "service[autocompleted]", :immediately
  mode "0644"
end

s3_credentials = search(:credentials, "usage:s3 AND usage:doat-bootstrap").first
aws_s3_file node[:doat][:autocompleted][:dump_file] do
  aws_access_key_id s3_credentials[:access_key_id]
  aws_secret_access_key s3_credentials[:secret_access_key]
  bucket "doat-bootstrap"
  key node[:doat][:autocompleted][:s3_dump_key]
  owner "doat"
  mode "0640"
  notifies :restart, "service[autocompleted]", :immediately
  action :create_if_missing
end

service "autocompleted" do
  restart_command "stop autocompleted; start autocompleted"
  action :enable
  provider ::Chef::Provider::Service::Upstart
end

service "cored" do
  restart_command "stop cored; start cored"
  action :enable
  provider ::Chef::Provider::Service::Upstart
end

provide_service(:core_master) if node[:doat][:core][:type] == "master"

# run the migrate script only once
if node[:redis][:instances][:melt][:replication][:role] == "master"
  execute "/opt/doat/core/Core/src/migrate.py --conf /etc/doat/core.conf" do
    user "doat"
    cwd "/opt/doat/core/Core/src/"
    not_if { ::File.exists?("/etc/doat/migrate.lock") }
    notifies :create, "file[/etc/doat/migrate.lock]"
  end
  file "/etc/doat/migrate.lock" do
    action :nothing
  end
end

provide_service(:core)
