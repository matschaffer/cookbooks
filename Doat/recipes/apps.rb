include_recipe "Doat::webserver_common"

%w(apps).each do |component|
  doat_svn component
end

app_config = data_bag_item(:doat_config, :apps)
sql = search(:endpoints, "type:rds AND db:#{app_config["db"]}").first
sql_credentials = search(:credentials, "usage:db_#{app_config["db"]}").first
memcache_nodes = all_providers_for_service(:memcached)

template "/opt/doat/apps/_common/Settings.local.php" do
  source "prod-apps-settings.php.erb"
  notifies :restart, "service[php-cgi]" if node[:php][:apc][:stat] == 0
  variables :sql => sql, :sql_credentials => sql_credentials, :app_config => app_config, :memcache_nodes => memcache_nodes
  mode "0644"
end

template ::File.join(node[:nginx][:dir], "sites-enabled", "doat-apps") do
  source "nginx-apps.conf.erb"
  notifies :reload, "service[nginx]"
  mode "0644"
end

nginx_site "doat-apps"
