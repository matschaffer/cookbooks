include_recipe "Doat::webserver_common"

%w(www/app www/gondor www/libraries).each do |component|
  doat_svn component
end

app_config = data_bag_item(:doat_config, :webapp)
sql = search(:endpoints, "type:rds AND db:#{app_config[:db]}").first
sql_credentials = search(:credentials, "usage:db_#{app_config[:db]}").first

template "/opt/doat/www/app/config/local.config.php" do
  source "webapp-local.config.php.erb"
  notifies :restart, "service[php-cgi]" if node[:php][:apc][:stat] == 0
  variables :sql => sql, :sql_credentials => sql_credentials, :app_config => app_config
end

template ::File.join(node[:nginx][:conf_dir], "sites-enabled", "doat-webui") do
  source "nginx-webui.conf.erb"
  notifies :reload, "service[nginx]"
end

template ::File.join(node[:nginx][:conf_dir], "sites-enabled", "doat-developer") do
  source "nginx-developer.conf.erb"
  notifies :reload, "service[nginx]"
end

nginx_site "doat-webui"
nginx_site "doat-developer"
