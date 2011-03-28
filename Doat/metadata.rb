maintainer       "Opscode, Inc."
maintainer_email "cookbooks@opscode.com"
license          "Apache 2.0"
description      "Installs/Configures Doat"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.1"
supports         "ubuntu", ">= 10.04"

%w(aws subversion cluster_service_discovery redis python apt php nginx pen).each do |dep|
  depends dep
end
