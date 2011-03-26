# Configures the melt datasync server
#
include_recipe "Doat"

link "/etc/init.d/synqd" do
  to "/opt/doat/etc/servers/core/init.d/synqd"
end

service "synqd" do
  action [:enable, :start]
end
