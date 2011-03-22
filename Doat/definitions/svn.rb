require 'uri'
# get data bag outside of passed block, we only need to call data_bag_item once
common_settings = data_bag_item('doat_config', 'common')

define :doat_svn do
  repo_url = common_settings['repo_url']
  repo_url = repo_url + '/' unless repo_url.end_with?('/')
  
  if params[:name].include?('/')
    directory ::File.join("/opt/doat", ::File.dirname(params[:name])) do
      owner "doat"
      group "doat"
      mode "0755"
    end
  end

  subversion ::File.join("/opt/doat", params[:name]) do
    repository ::URI.join(repo_url, params[:name]).to_s
    user "doat"
    group "doat"
    svn_arguments "--non-interactive --no-auth-cache --trust-server-cert"
    svn_info_args "--non-interactive --no-auth-cache --trust-server-cert"
    svn_username common_settings['repo_user']
    svn_password common_settings['repo_password']
  end
end
