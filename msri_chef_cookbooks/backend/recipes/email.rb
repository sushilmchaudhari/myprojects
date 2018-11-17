#
# Cookbook:: backend
# Recipe:: email.rb
#
# Copyright:: 2017, The Authors, All Rights Reserved.

apt_package 'Install Postfix' do
  package_name 'mailutils'
  action :install
end

service 'postfix' do
  action [:enable, :stop]
end 

template '/etc/postfix/main.cf' do
  source 'main.cf.erb'
  owner 'root'
  group 'root'
  mode '0644'
  action :create
end

ruby_block "insert_line" do
  block do
    file = Chef::Util::FileEdit.new("/etc/aliases")
    file.insert_line_if_no_match("root:    systems@msri.org", "root:    systems@msri.org")
    file.write_file
  end
end

file "/etc/postfix/generic" do
  content "root@msri.org systems@msri.org"
  owner 'root'
  group 'root'
  mode '0644'
  action :create
end

execute 'postmap-sasl_passwd' do
  command "postmap hash:#{node['postfix']['sasl_password_file']}"
  action :nothing
end

template node['postfix']['sasl_password_file'] do
  sensitive true
  source 'sasl_password.erb'
  owner 'root'
  group 'root'
  mode '600'
  notifies :run, 'execute[postmap-sasl_passwd]', :immediately
  notifies :restart, 'service[postfix]'
end

service 'postfix' do
  action :restart
end
