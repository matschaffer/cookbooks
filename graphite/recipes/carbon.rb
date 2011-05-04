include_recipe "graphite::common"
include_recipe "graphite::whisper"

directory node[:graphite][:storage_dir]

template ::File.join(node[:graphite][:dir], "carbon.conf") do
  notifies :restart, "service[carbon-cache]"
end

template ::File.join(node[:graphite][:dir], "storage-schemas.conf")

if node[:graphite][:install_flavor] == "source"
  include_recipe "graphite::carbon_source"
else
  package "python-carbon"
  service "carbon-cache" do
    action :start
  end
end


provide_service("graphite-carbon")
