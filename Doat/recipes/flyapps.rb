include_recipe "Doat::webserver_common"

%w(apps).each do |component|
  doat_svn component
end

app_config = data_bag_item(:doat_config, :flyapps)
sql = search(:endpoints, "type:rds AND db:#{app_config[:db]}").first
sql_credentials = search(:credentials, "usage:db_#{app_config[:db]}").first

template "/opt/doat/apps/_common/Settings.local.php" do
  source "prod-apps-settings.php.erb"
  notifies :restart, "service[php-cgi]" if node[:php][:apc][:stat] == 0
  variables :sql => sql, :sql_credentials => sql_credentials, :app_config => app_config
end

template ::File.join(node[:nginx][:conf_dir], "sites-enabled", "doat-flyapps") do
  source "nginx-flyapps.conf.erb"
  notifies :reload, "service[nginx]"
end

nginx_site "doat-flyapps"
