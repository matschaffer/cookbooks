package "python-twisted"

remote_file "/usr/src/carbon-#{node.graphite.carbon.version}.tar.gz" do
  source node.graphite.carbon.uri
  checksum node.graphite.carbon.checksum
end

execute "untar carbon" do
  command "tar xzf carbon-#{node.graphite.carbon.version}.tar.gz"
  creates "/usr/src/carbon-#{node.graphite.carbon.version}"
  cwd "/usr/src"
end

execute "install carbon" do
  command "python setup.py install"
  creates "/opt/graphite/lib/carbon-#{node.graphite.carbon.version}-py2.6.egg-info"
  cwd "/usr/src/carbon-#{node.graphite.carbon.version}"
end

service "carbon-cache" do
  start_command "/opt/graphite/bin/carbon-cache.py start"
  stop_command "/opt/graphite/bin/carbon-cache.py stop"
  action :start
end
