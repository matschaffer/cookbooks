#
# Author::  Joshua Timberman (<joshua@opscode.com>)
# Cookbook Name:: php
# Recipe:: pear_channel
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

define :pear_channel, :enable => true do
  
  include_recipe "php::pear"
  
  if params[:enable]
    execute "/usr/bin/pear channel-discover #{params[:name]}" do
      not_if "/usr/bin/pear channel-info #{params[:name]}"
    end
  end
  
end
