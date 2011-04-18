#
# Author::  Joshua Timberman (<joshua@opscode.com>)
# Cookbook Name:: php
# Recipe:: module_apc
#
# Copyright 2009, Opscode, Inc.
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

pack = value_for_platform([ "centos", "redhat", "fedora", "suse" ] => {"default" => "php-pecl-apc"}, "default" => "php5-apc")
if pack
  package pack do
    action :install
  end
end

#Xcache has conflicts with apc
xcache_pack = value_for_platform([ "centos", "redhat", "fedora", "suse" ] => {"default" => "php-pecl-xcache"}, "default" => "php5-xcache")
package xcache_pack do
  action :remove
end

file "/etc/php5/conf.d/xcache.ini" do
  action :delete
end

template "/etc/php5/conf.d/apc.ini" do
  source "apc.ini.erb"
end

