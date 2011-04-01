include_recipe "Doat::webserver_common"
include_recipe "php::module_curl"

["www/app","www/libraries", "developer", "bin/#{node[:doat][:arch]}"].each do |component|
  doat_svn component
end

app_config = data_bag_item(:doat_config, :webapp)
sql = search(:endpoints, "type:rds AND db:#{app_config["db"]}").first
sql_credentials = search(:credentials, "usage:db_#{app_config["db"]}").first
cores = all_providers_for_service(:core).reduce({}) do |cores_hash, core|
  cores_hash[core[:ipaddress]] = core[:doat][:core][:port]
  cores_hash
end

template "/opt/doat/www/app/config/local.config.php" do
  source "webapp-local.config.php.erb"
  notifies :restart, "service[php-cgi]" if node[:php][:apc][:stat] == 0
  variables :sql => sql, :sql_credentials => sql_credentials, :app_config => app_config, :cores => cores
  mode "0644"
end

template ::File.join(node[:nginx][:dir], "sites-available", "doat-webui") do
  source "nginx-webui.conf.erb"
  notifies :reload, "service[nginx]"
  mode "0644"
end

template ::File.join(node[:nginx][:dir], "sites-available", "doat-developer") do
  source "nginx-developer.conf.erb"
  notifies :reload, "service[nginx]"
  mode "0644"
end

nginx_site "doat-webui"
nginx_site "doat-developer"
