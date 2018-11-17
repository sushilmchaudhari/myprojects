#
# Cookbook:: proxy
# Recipe:: commons_conf
#
# Copyright:: 2018, The Authors, All Rights Reserved.

cookbook_file "/var/www/html/index.html" do
  source 'index.html'
  notifies :reload, 'service[nginx]', :delayed
end

template 'nginx.conf' do
  path   "#{node['nginx']['dir']}/conf/nginx.conf"
  source 'nginx.conf.erb'
  notifies :reload, 'service[nginx]', :delayed
  variables(lazy { { pid_file: node['nginx']['pidfile_location'] } })
end

template "#{node['nginx']['dir']}/sites-available/default" do
  source 'default-site.erb'
  notifies :reload, 'service[nginx]', :delayed
end

template "#{node['nginx']['dir']}/sites-available/www.msri.org" do
  source 'www-msri-org.erb'
  notifies :reload, 'service[nginx]', :delayed
end

template "#{node['nginx']['dir']}/sites-available/ssl.www.msri.org" do
  source 'ssl-www-msri-org.erb'
  notifies :reload, 'service[nginx]', :delayed
end

template "#{node['nginx']['dir']}/sites-available/locomotive.msri.org" do
  source 'locomotive-msri-org.erb'
  notifies :reload, 'service[nginx]', :delayed
end


