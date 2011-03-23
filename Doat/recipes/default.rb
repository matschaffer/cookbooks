#
# Cookbook Name:: Doat
# Recipe:: default
#
# Copyright 2011, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
include_recipe "apt"

apt_repository "doat-s3" do
  key "5B26B6739742320A9AB12D674DAB07B9B95D95FC"
  keyserver "keyserver.ubuntu.com"
  uri "http://doat-apt.s3.amazonaws.com/"
  distribution node[:lsb][:codename]
  components %w(main)
  action :add
end

user "doat" do
  supports :manage_home => true
  action [:create, :manage]
end

group "doat"

directory "/etc/doat" do
  mode "0755"
end

directory "/var/log/doat" do
  mode "0777"
end

directory "/var/run/doat" do
  owner "doat"
  mode "0755"
end

directory "/opt/doat" do
  owner "doat"
  group "doat"
end

file "/etc/ld.so.conf.d/doat.conf" do
  content "/opt/doat/bin/#{node[:doat][:arch]}"
  mode "0644"
  notifies :run, "execute[ldconfig]"
end

execute "ldconfig" do
  action :nothing
end

