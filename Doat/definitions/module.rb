require 'uri'

define :doat_module do
  include_recipe "subversion"
  common_settings = data_bag_item('doat_config', 'common')
  app_settings = data_bag_item('doat_config', params[:name])
  repo_url = common_settings['builds_base']
  repo_url = repo_url + '/' unless repo_url.end_with?('/')
  
  if params[:name].include?('/')
    directory ::File.join("/opt/doat", ::File.dirname(params[:name])) do
      owner "doat"
      group "doat"
      mode "0755"
    end
  end

  export_dir = ::File.join("/opt/doat", params[:name] + ".latest_#{node[:cluster][:environment]}")
  link_name = ::File.join("/opt/doat", params[:name])
  subversion export_dir do
    repository ::URI.join(repo_url, params[:name] + "/latest_#{node[:cluster][:environment]}").to_s
    user "doat"
    group "doat"
    svn_arguments "--non-interactive --no-auth-cache --trust-server-cert"
    svn_info_args "--non-interactive --no-auth-cache --trust-server-cert"
    svn_username common_settings['repo_user']
    svn_password common_settings['repo_password']
    action :export
  end

  link link_name do
    to export_dir
  end

  # config files links
  if app_settings.has_key? "config_files"
    app_settings["config_files"].each do |confname, linkname|
      link ::File.join(export_dir, linkname) do
        to confname
      end
    end
  end
end
