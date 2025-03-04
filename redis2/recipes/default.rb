#
# Cookbook Name:: redis
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
include_recipe "runit"
if node[:redis][:install_from] == "package"
  include_recipe "redis2::package"
else
  include_recipe "redis2::source"
end

user node[:redis][:user] do
  home node[:redis][:data_dir]
  system true
end

directory node[:redis][:instances][:default][:data_dir] do
  owner node[:redis][:user]
  mode "0750"
  recursive true
end

directory node[:redis][:conf_dir]

directory node[:redis][:pid_dir] do
  owner node[:redis][:user]
  mode "0750"
  recursive true
end

service "redis" do
  service_name value_for_platform(:default => "redis", [:ubuntu, :debian] => {:default => "redis-server"})
  action [:disable, :stop]
  ignore_failure true
end
