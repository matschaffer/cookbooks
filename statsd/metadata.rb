maintainer       "Fewbytes"
maintainer_email "avishai@fewbytes.com"
license          "All rights reserved"
description      "Installs/Configures statsd"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.1"
 
depends "cluster_service_discovery"
depends "nodejs"
depends "graphite"
