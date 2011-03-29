# Configures the melt datasync server
#
include_recipe "Doat"

cookbook_file "/etc/init/synqd.conf" do
  source "synqd.upstart.conf"
end

template "/etc/doat/synq.py" do
  source "synq.config.erb"
  mode "0644"
  notifies :restart, "service[synqd]"
end

service "synqd" do
  action [:enable, :start]
end
