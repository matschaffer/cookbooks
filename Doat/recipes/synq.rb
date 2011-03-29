# Configures the melt datasync server
#
include_recipe "Doat"

cookbook_file "/etc/init/synqd.conf" do
  source "synqd.upstart.conf"
end

app_config = data_bag_item(:doat_config, :core)
sql_host = search(:endpoints, "type:rds AND db:#{app_config["db"]}").first
sql_credentials = search(:credentials, "usage:db_#{app_config["db"]}").first
template "/etc/doat/synqd.py" do
  source "synqd.config.erb"
  mode "0644"
  notifies :restart, "service[synqd]"
  variables :sql => sql_host, :sql_credentials => sql_credentials
end

service "synqd" do
  action [:enable, :start]
  provider ::Chef::Provider::Service::Upstart
end
