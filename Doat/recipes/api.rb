include_recipe "Doat::webserver_common"

package "phpunit"
package "php5-thrift"

doat_svn "bin/#{node[:doat][:arch]}"

directory "/mnt/nginx/cache/api" do
  recursive true
  owner "www-data"
  mode "0755"
end

directory "/mnt/nginx/tmp" do
  owner "www-data"
  mode "0755"
end

link "/etc/php5/conf.d/thrift.ini" do
  to "/etc/php.d/thrift_protocol.ini"
  notifies :restart, "service[php5-fpm]"
end

template "/etc/doat/api.settings.local.php" do
  source "api-Settings.local.php.erb"
  notifies :restart, "service[php5-fpm]" if node[:php][:apc][:stat] == 0
  mode "0644"
end

doat_module "api"

socket = node[:php][:fpm][:pools][:default][:socket]
socket = "unix:" + socket if socket.start_with? "/"
template ::File.join(node[:nginx][:dir], "sites-available", "doat-api") do
  source "nginx-api.conf.erb"
  variables :socket => socket
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
  arguments "-C 9099 -n -b 0 -T 2 -r -x 500"
end

nginx_site "doat-api"
