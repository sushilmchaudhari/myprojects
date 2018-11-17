#
# Cookbook:: pass_nginx
# Recipe:: common_dirs
#
# Copyright:: 2018, The Authors, All Rights Reserved.

directory node['nginx']['log_dir'] do
  mode      '0755'
  owner     'root'
  group     'root'
  action    :create
  recursive true
end

%w(sites-available sites-enabled conf.d certs).each do |leaf|
  directory File.join(node[:passenger][:production][:path], leaf) do
    mode  '0755'
  end
end

