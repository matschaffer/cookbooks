include_recipe "Doat::webserver_common"
%w(channel://pear.php.net/Net_URL2-0.3.1
   channel://pear.php.net/HTTP_Request2-2.0.0beta2
   channel://pear.php.net/HTTP_OAuth-0.2.2
   channel://pear.php.net/Services_Digg2-0.3.2
  ).each do |pkg|
  pear_module pkg do
    enable true
  end
end

app_config = data_bag_item(:doat_config, :apps)
sql = search(:endpoints, "type:rds AND db:#{app_config["db"]}").first
sql_credentials = search(:credentials, "usage:db_#{app_config["db"]}").first
memcache_nodes = all_providers_for_service(:memcached)

template "/etc/doat/apps.settings.local.php" do
  source "prod-apps-settings.php.erb"
  notifies :restart, "service[php-cgi]" if node[:php][:apc][:stat] == 0
  variables :sql => sql, :sql_credentials => sql_credentials, :app_config => app_config, :memcache_nodes => memcache_nodes
  mode "0644"
end

doat_module "apps"

template ::File.join(node[:nginx][:dir], "sites-available", "doat-apps") do
  source "nginx-apps.conf.erb"
  notifies :reload, "service[nginx]"
  mode "0644"
end

nginx_site "doat-apps"
