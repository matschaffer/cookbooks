#
# Cookbook Name:: sysctl
# Recipe:: default
#
# Copyright 2011, Fewbytes Technologies LTD
#

def compile_attr(prefix, v)
  if v.respond_to? :map
    prefix += "." unless prefix.empty?
    return v.map {|key, value| compile_attr("#{prefix}#{key}", value)}.flatten
  end
  "#{prefix}=#{v}"
end

attr_txt = compile_attr("", node[:sysctl]).join("\n") + "\n"

if node.attribute? :sysctl
  file "/etc/sysctl.d/68-chef-attributes.conf" do
    content attr_txt
    mode "0644"
    notifies :start, "service[procps]"
  end
end

cookbook_file "/etc/sysctl.d/69-chef-static.conf" do
  ignore_failure true
  mode "0644"
  notifies :start, "service[procps]"
end

service "procps"
