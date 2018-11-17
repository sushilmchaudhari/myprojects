#
# Cookbook:: proxy
# Recipe:: commons_script
#
# Copyright:: 2018, The Authors, All Rights Reserved.

%w(nxensite nxdissite).each do |nxscript|
  template "#{node['nginx']['script_dir']}/#{nxscript}" do
    source "#{nxscript}.erb"
    mode   '0755'
  end
end

