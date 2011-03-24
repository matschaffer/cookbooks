default[:doat][:arch] = case kernel[:machine]
                        when "i368", "i686" then "i386"
                        when "amd64", "x86_64" then "x86_64"
                        end
