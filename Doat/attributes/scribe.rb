include_attribute "Doat"
default[:scribe][:tmp_dir]  = "/mnt/scribe_tmp"
default[:scribe][:user]     = "scribe"
default[:scribe][:group]    = "scribe"
default[:scribe][:port]     = 1463
default[:scribe][:conf_dir] = "/etc/scribe"
default[:scribe][:daemon]   = "/opt/doat/bin/#{doat[:arch]}/scribed"
