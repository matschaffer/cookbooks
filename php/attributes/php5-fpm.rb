default[:php][:fpm][:sockets_dir] = "/var/run/php5"
default[:php][:fpm][:pools_dir] = "/etc/php5/fpm/pool.d"
default[:php][:fpm][:pools][:default][:enable] = true
default[:php][:fpm][:pools][:default][:user] = "www-data"
default[:php][:fpm][:pools][:default][:group] = "www-data"
default[:php][:fpm][:pools][:default][:port] = 9000
default[:php][:fpm][:pools][:default][:listen_backlog] = -1
# default[:php][:fpm][:pools][:default][:allowed_clients] = %w(127.0.0.1)
default[:php][:fpm][:pools][:default][:pm][:type] = "dynamic" # or static
default[:php][:fpm][:pools][:default][:pm][:max_children] = 50
default[:php][:fpm][:pools][:default][:pm][:max_spare_servers] = 35
default[:php][:fpm][:pools][:default][:pm][:min_spare_servers] = 5
default[:php][:fpm][:pools][:default][:pm][:start_servers] = \
  default[:php][:fpm][:pools][:default][:pm][:min_spare_servers] + (default[:php][:fpm][:pools][:default][:pm][:max_spare_servers] - default[:php][:fpm][:pools][:default][:pm][:min_spare_servers]) / 2

default[:php][:fpm][:pools][:default][:pm][:max_requests] = 0
