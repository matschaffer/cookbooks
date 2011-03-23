default[:scribe][:tmp_dir]  = "/mnt/scribe_tmp"
default[:scribe][:user]     = "scribe"
default[:scribe][:group]    = "scribe"
default[:scribe][:port]     = 1463
default[:scribe][:conf_dir] = "/etc/scribe"
default[:scribe][:daemon]   = case kernel[:machine]
                              when "i686", "i386"
                                "/opt/doat/bin/i386/scribd"
                              when "x86_64", "amd64"
                                "/opt/doat/bin/x86_64/scribd"
                              end
