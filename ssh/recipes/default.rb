package 'ssh'

template ::File.join(node[:ssh][:dir], "sshd_config") do
  source "sshd_config.erb"
  notifies :restart, "service[ssh]"
end

service "ssh" do
  action [:start, :enable]
end

admin_keys = []
users = []
admin_groups = node[:ssh][:admin_groups] || [ "admins" ]
admin_groups_query = admin_groups.map do |grp|
  "groups:#{grp}"
end.join(" OR ")
search("users", "(#{admin_groups_query}) AND ssh_public_key:[* TO *]").each do |user|
  admin_keys.push user['ssh_public_key'].chomp
  users.push user['id']
end
Chef::Log.info "Adding SSH keys for #{users.join(", ")}" if users.any?
ruby_block "Manage root's authorized_keys" do
  block do
    ::File.open("/root/.ssh/authorized_keys", "a+") do |f|
      keys_to_add = admin_keys - f.readlines
      keys_to_add.each do |public_key|
        f.puts public_key
      end
    end
  end
end

directory "/root/.ssh" do
  owner "root"
  mode "0700"
end

