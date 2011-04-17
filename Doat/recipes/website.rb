include_recipe "Doat::webserver_common"
include_recipe "php::module_curl"

app_config = data_bag_item("doat_config", "website")
sql = search(:endpoints, "type:rds AND db:#{app_config["db"]}").first
sql_credentials = search(:credentials, "usage:db_#{app_config["db"]}").first
cores = all_providers_for_service(:core).reduce({}) do |cores_hash, core|
  cores_hash[core[:ipaddress]] = core[:doat][:core][:port]
  cores_hash
end

template "/etc/doat/website.local.config.php" do
  source "website-local.config.php.erb"
  notifies :restart, "service[php5-fpm]" if node[:php][:apc][:stat] == 0
  variables :sql => sql, :sql_credentials => sql_credentials, :app_config => app_config, :cores => cores
  mode "0644"
end

template "/etc/doat/developer.settings.local.php" do
  source "website-local.config.php.erb"
  notifies :restart, "service[php5-fpm]" if node[:php][:apc][:stat] == 0
  variables :sql => sql, :sql_credentials => sql_credentials, :app_config => app_config, :cores => cores
  mode "0644"
end

socket = node[:php][:fpm][:pools][:default][:socket]
socket = "unix:" + socket if socket.start_with? "/"
template ::File.join(node[:nginx][:dir], "sites-available", "doat-website") do
  source "nginx-website.conf.erb"
  notifies :reload, "service[nginx]"
  mode "0644"
  variables :socket => socket
end

doat_module "website"
doat_module "developer"

template ::File.join(node[:nginx][:dir], "sites-available", "doat-developer") do
  source "nginx-developer.conf.erb"
  notifies :reload, "service[nginx]"
  variables :socket => socket
  mode "0644"
end

nginx_site "doat-website"
nginx_site "doat-developer"
