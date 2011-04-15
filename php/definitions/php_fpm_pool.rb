# Usage:
# php_fpm_pool "myapp" do
#   bind "0.0.0.0"
#   port "9000"
#   user "www-data"
#   group "www-data"
#   chroot "/var/www/myapp"
# end
# 
# Or for unix domain sockets:
# php_fpm_pool "myapp" do
#   bind "/var/run/myapp.sock"
# end
#
# By default the pool will bind to ::File.join(default[:php][:fpm][:sockets_dir], params[:name] + ".sock")

define :php_fpm_pool do
  node[:php][:fpm][:pools][params[:name]][:user] = params[:user] if params[:user]
  node[:php][:fpm][:pools][params[:name]][:group] = params[:group] if params[:group]
  unless params[:name] == "default"
    conf = ::Chef::Node::Attribute.new(
      ::Chef::Mixin::DeepMerge.merge(node.normal[:php][:fpm][:pools][:default].to_hash, node.normal[:php][:fpm][:pools][params[:name]].to_hash),
      ::Chef::Mixin::DeepMerge.merge(node.default[:php][:fpm][:pools][:default].to_hash, node.default[:php][:fpm][:pools][params[:name]].to_hash),
      ::Chef::Mixin::DeepMerge.merge(node.override[:php][:fpm][:pools][:default].to_hash, node.override[:php][:fpm][:pools][params[:name]].to_hash),
      {})
  else
    conf = node[:php][:fpm][:pools][:default]
  end

  if params.has_key?(:bind) and not params[:bind].start_with?("/")
    params[:bind] += ":" + params[:port]
  else
    params[:bind] = ::File.join(node[:php][:fpm][:sockets_dir], params[:name] + ".sock")
  end
  node[:php][:fpm][:pools][params[:name]][:socket] = params[:bind]

  chdir = value_for_platform(
    [:debian, :ubuntu] => {"default" => "/var/www"},
    [:centos, :redhat, :fedora] => {"default" => "/var/www/html"},
    "default" => "/srv/www"
  )

  template ::File.join(node[:php][:fpm][:pools_dir], params[:name]) do
    mode "0644"
    source "php5-fpm-pool.conf.erb"
    variables :pool_conf => conf, :socket => node[:php][:fpm][:pools][params[:name]][:socket],
      :chroot_dir => params.fetch(:chroot, nil), :chdir => chdir
    notifies :restart, "service[php5-fpm]"
  end
end
