include_recipe "apache2::mod_wsgi"
include_recipe "graphite::common"

if node[:graphite][:install_flavor] == "source"
  include_recipe "graphite::web_source"
else
  template "/etc/apache2/sites-available/graphite" do
    source "graphite-vhost.conf.erb"
  end

  template ::File.join(node[:graphite][:webapp_dir], "graphite", "graphite.wsgi")

  apache_site "graphite"

  directory ::File.join(node[:graphite][:log_dir], "webapp") do
    owner node[:apache][:user]
    group node[:apache][:group]
  end

  directory node[:graphite][:storage_dir] do
    owner node[:apache][:user]
    group node[:apache][:group]
  end

  cookbook_file ::File.join(node[:graphite][:storage_dir], "graphite.db") do
    owner node[:apache][:user]
    group node[:apache][:group]
    action :create_if_missing
  end
end
provide_service("graphite-web")
