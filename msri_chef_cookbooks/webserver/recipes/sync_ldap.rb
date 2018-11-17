#
# Cookbook:: webserver
# Recipe:: sync_ldap
#
# Copyright:: 2018, The Authors, All Rights Reserved.

# Local attributes

default_ruby_version = node[:rvm][:install][:rubies].last
rvm_cmd = "#{node[:rvm][:path]}/bin/rvm"

execute  'Install Bugsnag gem' do
  command "#{node[:rvm][:path]}/gems/#{default_ruby_version}@sync_ldap/wrappers/gem install bugsnag"
  not_if "ls #{node[:rvm][:path]}/gems/#{default_ruby_version}@sync_ldap/gems | grep bugsnag"
end

execute  'Install Bugsnag gem' do
  command "#{node[:rvm][:path]}/gems/#{default_ruby_version}@sync_ldap/wrappers/gem install httpparty"
  not_if "ls #{node[:rvm][:path]}/gems/#{default_ruby_version}@sync_ldap/gems | grep httpparty"
end

directory '/opt/msri/scripts' do
  mode      '0755'
  owner     'msri'
  group     'msri'
  action    :create
  recursive true
end

cookbook_file '/opt/msri/scripts/sync_ldap.rb' do
  source 'sync_ldap.rb'
  owner 'msri'
  group 'msri'
  mode '0500'
  action :create
end

file "/opt/msri/scripts/sync_ldap.sh" do
  owner 'msri'
  group 'msri'
  mode '0500'
  action :create
  content <<-EOL
#!/bin/bash

source /usr/local/rvm/environments/ruby-2.5.0@sync_ldap
/opt/msri/scripts/sync_ldap.rb
  EOL
end

cron 'sync_ldap cron entry' do
  minute '*/5'
  user 'msri'
  command "/opt/msri/scripts/sync_ldap.sh >> /opt/msri/apps/#{node['rails']['deploy']['dir']}/shared/log/sync_ldap.crontab.log 2>&1"
end
