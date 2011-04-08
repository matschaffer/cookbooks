package 'ssh'

template ::File.join(node[:ssh][:dir], "sshd_config") do
  source "sshd_config.erb"
  notifies :restart, "service[ssh]"
end

service "ssh" do
  action [:start, :enable]
end

user_keys = {}
root_keys = []
admin_groups = node[:ssh][:admin_groups] || [ "admins" ]
search("users", "ssh_public_key:[* TO *]").each do |user|
  user_name = nil
  user_name = user["remote_user"] if user.has_key? "remote_user"
  if (user["groups"] & admin_groups).any?
    root_keys << user["ssh_public_key"]
  end
  unless user_name.nil?
    user_keys[user_name] = 
      user_keys.fetch(user_name, Array.new).push(user["ssh_public_key"].chomp)
  end
end

ruby_block "Manage root's authorized_keys" do
  block do
    ::File.open("/root/.ssh/authorized_keys", "a+") do |f|
      keys_to_add = root_keys - f.readlines.map{|l| l.chomp}
      keys_to_add.each do |public_key|
        f.puts public_key
      end
    end
  end
end

user_keys.each do |user, keys|
  auth_keys_file = begin
    ::File.join(node[:etc][:passwd][user][:dir], ".ssh", "authorized_keys")
                   rescue
                     "/home/#{user}/.ssh/authorized_keys"
                   end
  file auth_keys_file do
    content keys.join('\n')
    owner user
    mode "0700"
    ignore_failure true
  end
end

directory "/root/.ssh" do
  owner "root"
  mode "0700"
end

