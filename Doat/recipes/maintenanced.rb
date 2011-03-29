include_recipe "Doat"

git_repository "/opt/doat/maintenanced" do
  repository "ssh://doat@jira.doit9.com/var/lib/git/maintenanced.git"
  user "doat"
  action :sync
end

credentials = search(:credentials, "usage:sns AND usage:maintenanced").first
template "/etc/doat/maintenanced.conf" do
  source "maintenanced.conf.erb"
  mode "0644"
  notifies :restart, "service[maintenanced]"
  variables :credentials => credentials
end

cookbook_file "/etc/init/maintenanced.conf" do
  source "maintenanced.upstart.conf"
  mode "0644"
end

service "maintenanced" do
  action [:start, :enable]
  provider ::Chef::Provider::Service::Upstart
end


