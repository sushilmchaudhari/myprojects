#
# Cookbook:: proxy
# Recipe:: commons_dir
#
# Copyright:: 2018, The Authors, All Rights Reserved.

directory node['nginx']['dir'] do
  mode      '0755'
  recursive true
end

directory node['nginx']['log_dir'] do
  mode      '0755' 
  owner     'root'
  group	    'root'
  action    :create
  recursive true
end

directory 'pid file directory' do
  path       lazy { File.dirname(node['nginx']['pidfile_location']) }
  mode      '0755'
  recursive true
end

%w(conf logs sites-available sites-enabled conf.d).each do |leaf|
  directory File.join(node['nginx']['dir'], leaf) do
    mode  '0755'
  end
end

directory '/var/www/html' do
  mode      '0755'
  owner     'root'
  group     'root'
  action    :create
  recursive true
end
