# install and configure the autocomplete server
#
doat_module "autocompleted_bin" 

cookbook_file "/etc/init/autocompleted.conf" do
  source "autocompleted.upstart.conf"
end

template "/etc/doat/autocomplete.conf" do
  source "autocomplete.conf.erb"
  notifies :restart, "service[autocompleted]", :immediately
  mode "0644"
end

directory "/opt/doat/data" do
  owner "doat"
  group "doat"
  mode "0755"
end

# get a bootstrap file from s3
s3_credentials = search(:credentials, "usage:s3 AND usage:doat-bootstrap").first
aws_s3_file node[:doat][:autocompleted][:dump_file] do
  aws_access_key_id s3_credentials[:access_key_id]
  aws_secret_access_key s3_credentials[:secret_access_key]
  bucket "doat-bootstrap"
  key node[:doat][:autocompleted][:s3_dump_key]
  owner "doat"
  mode "0640"
  notifies :restart, "service[autocompleted]", :immediately
  action :create_if_missing
end

service "autocompleted" do
  restart_command "stop autocompleted; start autocompleted"
  action :enable
  provider ::Chef::Provider::Service::Upstart
end

