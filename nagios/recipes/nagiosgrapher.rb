package "nagiosgrapher"

remote_directory ::File.join(node[:nagios][:nagiosgrapher][:dir], "ngraph.d/chef_templates") do
  source "nagiosgrapher_templates"
  files_mode "0644"
  mode "0755"
  ignore_failure true
  notifies :restart, "service[nagiosgrapher]"
end

template "/etc/nagiosgrapher/ngraph.ncfg" do
  source "ngraph.ncfg.erb"
  mode "0644"
  notifies :restart, "service[nagiosgrapher]"
end

service "nagiosgrapher" do
  action [:enable, :start]
  supports :reload => false
end

execute "rm /etc/nagiosgrapher/nagios3/serviceext/*.cfg" do
  action :nothing
  subscribes :run, resources(:template => ["#{node[:nagios][:dir]}/conf.d/hosts.cfg", "#{node[:nagios][:dir]}/conf.d/services.cfg"]), :immediately
end

