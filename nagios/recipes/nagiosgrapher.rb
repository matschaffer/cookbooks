package "nagiosgrapher"

remote_directory ::File.join(node[:nagios][:nagiosgrapher][:dir], "ngraph.d/chef_templates") do
  source "nagiosgrapher_templates"
  files_mode "0644"
  mode "0755"
  ignore_failure true
  notifies :restart, "service[nagiosgrapher]"
end

service "nagiosgrapher" do
  action [:enable, :start]
  supports :reload => false
end
