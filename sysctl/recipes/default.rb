#
# Cookbook Name:: sysctl
# Recipe:: default
#
# Copyright 2011, Fewbytes Technologies LTD
#

def compile_attr(prefix, v)
  case v.class
  when Array
    return "#{prefix}=#{v.join(" ")}"
  when String
    "#{prefix}=#{v}"
  when Hash, Chef::Node::Attribute
    prefix += "." unless prefix.empty?
    return v.map {|key, value| compile_attr("#{prefix}#{key}", value)}.flatten
  else
    raise Chef::Exceptions::UnsupportedAction, "Sysctl cookbook can't handle values of type: #{v.class}"
  end
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
