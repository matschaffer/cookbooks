include_recipe "Doat::webserver_common"

package "phpunit"
package "php5-thrift"

doat_svn "bin/#{node[:doat][:arch]}"


link "/etc/php5/conf.d/thrift.ini" do
  to "/etc/php.d/thrift_protocol.ini"
  notifies :restart, "service[php-cgi]"
end

template "/etc/doat/api.settings.local.php" do
  source "api-Settings.local.php.erb"
  notifies :restart, "service[php-cgi]" if node[:php][:apc][:stat] == 0
  mode "0644"
end

doat_module "api"

template ::File.join(node[:nginx][:dir], "sites-available", "doat-api") do
  source "nginx-api.conf.erb"
  notifies :reload, "service[nginx]"
  mode "0644"
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
