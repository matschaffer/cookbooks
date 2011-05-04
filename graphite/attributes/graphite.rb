default[:graphite][:carbon][:line_receiver_interface]   = "127.0.0.1"
default[:graphite][:carbon][:line_receiver_port]        = 2003
default[:graphite][:carbon][:pickle_receiver_interface] = "127.0.0.1"
default[:graphite][:carbon][:pickle_receiver_port]      = 2004
default[:graphite][:carbon][:cache_query_interface]     = "127.0.0.1"
default[:graphite][:carbon][:cache_query_port]          = 7002

default[:graphite][:carbon][:version] = "0.9.8"
default[:graphite][:carbon][:uri] = "http://launchpadlibrarian.net/68173160/carbon-0.9.8.tar.gz"
default[:graphite][:carbon][:checksum] = "d48ae81b9e739c30132a3f885bde5c612b1531ce4db96b72018f173cccd2fb5e"

default[:graphite][:whisper][:version] = "0.9.8"
default[:graphite][:whisper][:uri] = "http://launchpadlibrarian.net/68173141/whisper-0.9.8.tar.gz"
default[:graphite][:whisper][:checksum] = "b915836a69e924ccbd6d9be8f8791c4cab93cea106de6825bb60edb3cb42957e"

default[:graphite][:graphite_web][:version] = "0.9.8"
default[:graphite][:graphite_web][:uri] = "http://launchpadlibrarian.net/68173206/graphite-web-0.9.8.tar.gz"
default[:graphite][:graphite_web][:checksum] = "810f183e245ab1944bfb331e88d8ac2df6dd1797be810e7cf6368d1ba7e4ccab"
default[:graphite][:graphite_web][:threads] = 20

default[:graphite][:dir] = "/etc/graphite"
default[:graphite][:storage_dir] = "/var/lib/graphite/storage"
default[:graphite][:log_dir] = "/var/log/graphite"
if graphite[:install_flavor] == "source"
  default[:graphite][:webapp_dir] = "/opt/graphite/webapp"
  default[:graphite][:django_root] = "/usr/lib/python2.6/site-packages/django"
else
  default[:graphite][:webapp_dir] = "/usr/share/graphite/webapp"
  default[:graphite][:django_root] = "/usr/share/pyshared/django"
end
