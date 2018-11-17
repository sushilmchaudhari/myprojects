#
# Cookbook:: pass_nginx
# Recipe:: common_scripts
#
# Copyright:: 2018, The Authors, All Rights Reserved.

%w(nxensite nxdissite).each do |nxscript|
  template "/usr/sbin/#{nxscript}" do
    source "#{nxscript}.erb"
    mode   '0755'
  end
end

