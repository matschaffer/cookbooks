include_recipe "Doat::webserver_common"

["www/app", "www/gondor", "www/libraries", "bin/#{node[:doat][:arch]}"].each do |component|
  doat_svn component
end

template "/opt/doat/www/gondor/services/doat/0.4/include/Settings.local.php" do
  source "api-Settings.local.php.erb"
  notifies :restart, "service[php-cgi]" if node[:php][:apc][:stat] == 0
end

template ::File.join(node[:nginx][:dir], "sites-enabled", "doat-api") do
  source "nginx-api.conf.erb"
  notifies :reload, "service[nginx]"
end

core_nodes = []
all_providers_for_service(:core).each do |core|
  core_nodes << {:host => core[:ipaddress], :port => core[:doat][:core][:port]}
end

pen_cluster "core" do
  port 9091
  nodes core_nodes
end

nginx_site "doat-api"
