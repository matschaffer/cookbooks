default[:ganglia][:version] = "3.1.7"
default[:ganglia][:uri] = "http://sourceforge.net/projects/ganglia/files/ganglia%20monitoring%20core/3.1.7/ganglia-3.1.7.tar.gz/download"
default[:ganglia][:checksum]      = "bb1a4953"
default[:ganglia][:cluster_name]  = "default"
default[:ganglia][:grid_name]     = "default"
default[:ganglia][:owner]         = "default"
default[:ganglia][:user]          = "ganglia"

default[:ganglia][:udp_recv_port] = 8649
default[:ganglia][:tcp_recv_port] = 8649
default[:ganglia][:multicast]     = true
default[:ganglia][:send_metadata_interval] = 20
