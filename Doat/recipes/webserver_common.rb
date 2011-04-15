include_recipe "Doat"
include_recipe "nginx"
include_recipe "php::module_curl"
include_recipe "php::module_apc"
include_recipe "php::php5-fpm"
include_recipe "Doat::scribe-client"

remote_directory ::File.join(node[:nginx][:dir], "ssl") do
  mode "0700"
  files_mode "0600"
  files_owner node[:nginx][:user]
  files_group node[:nginx][:group]
  owner node[:nginx][:user]
  group node[:nginx][:group]
  source "ssl"
  notifies :restart, "service[nginx]"
end
nginx_site "default" do
  enable false
end
