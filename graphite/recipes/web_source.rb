package "python-django"
package "python-memcache"
package "python-rrdtool"
package "python-cairo-dev"

remote_file "/usr/src/graphite-web-#{node.graphite.graphite_web.version}.tar.gz" do
  source node.graphite.graphite_web.uri
  checksum node.graphite.graphite_web.checksum
end

execute "untar graphite-web" do
  command "tar xzf graphite-web-#{node.graphite.graphite_web.version}.tar.gz"
  creates "/usr/src/graphite-web-#{node.graphite.graphite_web.version}"
  cwd "/usr/src"
end

remote_file "/usr/src/graphite-web-#{node.graphite.graphite_web.version}/webapp/graphite/storage.py.patch" do
  source "http://launchpadlibrarian.net/65094495/storage.py.patch"
  checksum "8bf57821"
end

execute "patch graphite-web" do
  command "patch storage.py storage.py.patch"
  creates ::File.join(node[:graphite][:webapp_dir], "graphite_web-#{node.graphite.graphite_web.version}-py2.6.egg-info")
  cwd "/usr/src/graphite-web-#{node.graphite.graphite_web.version}/webapp/graphite"
end

execute "install graphite-web" do
  command "python setup.py install"
  creates ::File.join(node[:graphite][:webapp_dir], "graphite_web-#{node.graphite.graphite_web.version}-py2.6.egg-info")
  cwd "/usr/src/graphite-web-#{node.graphite.graphite_web.version}"
end

