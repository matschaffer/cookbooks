include_recipe "graphite::common"

if node[:graphite][:install_flavor] == "source"
  include_recipe "graphite::whisper_source"
else
  package "python-whisper"
end
