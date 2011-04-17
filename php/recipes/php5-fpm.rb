#
# Author::  Avishai Ish-Shalom (<avishai@fewbytes.com>)
# Cookbook Name:: php
# Recipe:: php5-cgi
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
include_recipe "php::module_mysql"
include_recipe "php::module_sqlite3"
include_recipe "php::module_memcache"
include_recipe "php::module_gd"
include_recipe "php::module_pgsql"

www_pool = ::File.join(node[:php][:fpm][:pools_dir], "www.conf")
package value_for_platform([:ubuntu, :debian] => {"default" => "php5-fpm"},
                           ["centos", "redhat"] => {"default" => "php-fpm"},
                           "default" => "php5-fpm") do
  notifies :delete, "file[#{www_pool}]"
end

user "www-data" do
  gid "www-data"
  shell "/bin/true"
  home "/var/www"
end
directory node[:php][:fpm][:sockets_dir] do
  mode "0755"
end

file www_pool do
  action :nothing
end

memcache_servers = all_providers_for_service("memcached")
template value_for_platform([ "centos", "redhat", "suse" ] => {"default" => "/etc/php.ini"}, "default" => "/etc/php5/fpm/php.ini") do
  source "php.ini.erb"
  owner "root"
  group "root"
  mode 0644
  variables :memcache_servers => memcache_servers
  notifies :restart, "service[php5-fpm]", :delayed
end

php_fpm_pool "default" if node[:php][:fpm][:pools][:default][:enable]

service "php5-fpm" do
  action [:start, :enable]
end
