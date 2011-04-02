default[:elasticsearch][:tarball_url] = "http://github.com/downloads/elasticsearch/elasticsearch/elasticsearch-0.15.2.tar.gz"
default[:elasticsearch][:user]                = "elasticsearch"
default[:elasticsearch][:inst_dir]            = "/opt/elasticsearch"
default[:elasticsearch][:init_style]          = "init"
default[:elasticsearch][:pid_dir]             = "/var/run/elasticsearch"
default[:elasticsearch][:conf_dir]             = "/etc/elasticsearch"
default[:elasticsearch][:java][:max_memory] = "768m"
default[:elasticsearch][:java][:min_memory] = "256m"

# Everything under :es is converted to a json configuration file
default[:elasticsearch][:es][:cluster][:name] = "elasticsearch"
default[:elasticsearch][:es][:network][:host] = "0.0.0.0"
default[:elasticsearch][:es][:path][:logs]    = "/var/log/elasticsearch"
default[:elasticsearch][:es][:path][:data]    = "/var/lib/elasticsearch"
