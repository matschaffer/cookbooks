include_recipe "Doat"
include_recipe "python"
include_recipe "git"

redis_instance "geodis" 
package "unzip"
%w(redis hiredis geohasher python-geohash).each do |pkg|
  easy_install_package pkg
end

git "/opt/doat/geodis" do
  repository "git://github.com/doat/geodis.git"
  user "doat"
  action :sync
end

ip2location_credentials = data_bag_item(:credentials, "ip2location")
bash "initialize geodis" do
  cwd "/opt/doat/geodis/src"
  code <<-EOS
./geodis.py -g -f ../data/cities1000.txt
./geodis.py -z -f ../data/zipcode.csv
../external/ip2location/update.sh -l #{ip2location_credentials["username"]} -p #{ip2location_credentials["password"]} -g DB9 --redis-port #{node[:redis][:instances][:geodis][:port]} && touch /opt/doat/geodis/first_update.lock
EOS
  creates "/opt/doat/geodis/first_update.lock"
end

cron "run ip2location downloader" do
  day 5
  hour 7
  minute 0
  command "/opt/doat/geodis/external/ip2location/update.sh -l #{ip2location_credentials["username"]} -p #{ip2location_credentials["password"]} -g DB9 --redis-port #{node[:redis][:instances][:geodis][:port]}"
end
