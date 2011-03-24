include Opscode::Aws::S3

action :create do
  Chef::Log.debug "Fetching key object for #{new_resource.bucket}/#{new_resource.key}"
  s3_key = key(new_resource.bucket, new_resource.key)
  begin
    md5 = Digest::MD5.file(new_resource.path).hexdigest
  rescue Errno::ENOENT # file not found
    md5 = ""
  end
  unless md5 == s3_key.e_tag.delete('"')
    Chef::Log.info "MD5 of #{new_resource.path} differs from Etag of S3 key, downloading."
    f_owner = new_resource.owner
    f_group = new_resource.group
    f_mode = new_resource.mode
    f = file new_resource.path do
      content s3_key.data
      owner f_owner if f_owner
      group f_group if f_group
      mode f_mode if f_mode
      backup new_resource.backup
    end
    f.run_action(:create)
    # verify file
    md5 = Digest::MD5.file(new_resource.path).hexdigest
    raise RuntimeError, "MD5 sum of downloaded file doesn't match Etag!" unless md5 == s3_key.e_tag.delete('"')
    new_resource.updated_by_last_action true
  end
end

action :create_if_missing do
  action_create unless File.exists? new_resource.path
end
