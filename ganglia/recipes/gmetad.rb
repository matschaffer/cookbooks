case node[:platform]
when "ubuntu", "debian"
  package "gmetad"
when "redhat", "centos", "fedora"
  include_recipe "ganglia::source"
  execute "copy gmetad init script" do
    command "cp " +
      "/usr/src/ganglia-#{node[:ganglia][:version]}/gmetad/gmetad.init " +
      "/etc/init.d/gmetad"
    not_if "test -f /etc/init.d/gmetad"
  end
end

user node[:ganglia][:user] do
  system true
end

directory "/var/lib/ganglia/rrds" do
  owner node[:ganglia][:user]
  recursive true
end

hosts_per_cluster = search(:node, "recipes:ganglia").reduce({}) do |h,n|
  if n[:ganglia].has_key? :tcp_recv_port
    if h.has_key? n[:ganglia][:cluster_name]
      h[n[:ganglia][:cluster_name]].push "#{n.ipaddress}:#{n.ganglia.tcp_recv_port}"
    else
      h[n[:ganglia][:cluster_name]] = ["#{n.ipaddress}:#{n.ganglia.tcp_recv_port}"]
    end
  else
    Chef::Log.warn "#{n.name} doesn't have attribute ganglia.tcp_recv_port"
  end
  h
end

template "/etc/ganglia/gmetad.conf" do
  source "gmetad.conf.erb"
  variables :hosts_per_cluster => hosts_per_cluster
  notifies :restart, "service[gmetad]"
end

service "gmetad" do
  supports :restart => true
  action [ :enable, :start ]
end
