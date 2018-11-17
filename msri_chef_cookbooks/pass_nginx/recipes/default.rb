#
# Cookbook:: pass_nginx
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.


['curl', 'nodejs', 'libcurl4-openssl-dev'].each do |pkg|
    package pkg
end

default_ruby_version = "#{node[:rvm][:install][:rubies].last}@#{node[:rvm][:gemset].last}"
nginx_path = node[:passenger][:production][:path]
rvm_cmd = "#{node[:rvm][:path]}/bin/rvm"

log default_ruby_version

node.run_state['gem_binary'] = "#{node[:rvm][:path]}/wrappers/#{default_ruby_version}/gem"

# install Rack gem

gem_package 'rack' do
  action     :install
  version    node['rack']['version']
  gem_binary node.run_state['gem_binary'] 
end

# Install Passenger

gem_package 'passenger' do
  action     :install
  version    node['passenger']['version']
  gem_binary node.run_state['gem_binary']
end

# Install and compile nginx source from Passenger module

bash 'install_nginx_passenger' do
  code <<-EOB
    #{node[:rvm][:path]}/wrappers/#{default_ruby_version}/passenger-install-nginx-module --auto --auto-download --prefix="#{nginx_path}"
  EOB
  not_if "test -e #{nginx_path}/sbin/nginx"
end


# Create common nginx directory structre

include_recipe "pass_nginx::common_dirs"

# Template Nginx with Passenger_root and Ruby_root

include_recipe "pass_nginx::common_conf"

# Copy common scripts

include_recipe "pass_nginx::common_scripts"

# Nginx Service

template "/etc/init.d/nginx" do
  source "passenger.init.erb"
  owner "root"
  group "root"
  mode 0755
  variables(
    :pidfile => "#{nginx_path}/logs/nginx.pid",
    :nginx_path => nginx_path
  )
end

service "nginx" do
  service_name "nginx"
  enabled true
  running true
  reload_command "if [ -e #{nginx_path}/logs/nginx.pid ]; then #{nginx_path}/sbin/nginx -s reload; fi"
  start_command "#{nginx_path}/sbin/nginx"
  stop_command "if [ -e #{nginx_path}/logs/nginx.pid ]; then #{nginx_path}/sbin/nginx -s stop; fi"
  status_command "curl http://localhost/nginx_status"
  supports [ :start, :stop, :reload, :status, :enable ]
  action [ :enable, :start ]
  pattern "nginx: master"
end
