#
# Cookbook Name:: backend
# Recipe:: solr
#
# Copyright 2017, The Authors, All Rights Reserved.
#

node.override['java']['jdk_version'] = '8'

if node['solr']['install_java']
  include_recipe 'apt'
  include_recipe 'java'
end

extract_path = "#{node['solr']['dir']}-#{node['solr']['version']}"
solr_path = "#{extract_path}/#{node['solr']['version'].split('.')[0].to_i < 5 ? 'example' : 'server'}"

user node['solr']['user'] do
  comment 'User that owns the solr data dir.'
  home node['solr']['data_dir']
  system true
  shell '/bin/false'
  only_if { node['solr']['user'] != 'root' }
end

group node['solr']['group'] do
  members node['solr']['user']
  append true
  system true
  only_if { node['solr']['group'] != 'root' }
end

ark 'solr' do
  url node['solr']['url']
  version node['solr']['version']
  path node['solr']['dir']
  prefix_root '/opt'
  prefix_home '/opt'
  owner node['solr']['user']
  action :install
end

directory node['solr']['data_dir'] do
  owner node['solr']['user']
  group node['solr']['group']
  recursive true
  action :create
end

template '/var/lib/solr.start' do
  source 'solr.start.erb'
  owner 'root'
  group 'root'
  mode '0755'
  variables(
    :solr_dir => solr_path,
    :solr_home => node['solr']['data_dir'],
    :port => node['solr']['port'],
    :pid_file => node['solr']['pid_file'],
    :log_file => node['solr']['log_file'],
    :java_options => node['solr']['java_options']
  )
  only_if { !platform_family?('debian') }
end

template '/etc/init.d/solr' do
  source platform_family?('debian') ? 'initd.debian.erb' : 'initd.erb'
  owner 'root'
  group 'root'
  mode '0755'
  variables(
    :solr_dir => solr_path,
    :solr_home => node['solr']['data_dir'],
    :port => node['solr']['port'],
    :pid_file => node['solr']['pid_file'],
    :log_file => node['solr']['log_file'],
    :user => node['solr']['user'],
    :java_options => node['solr']['java_options']
  )
end

service 'solr' do
  supports :restart => true, :status => true
  action [:enable, :start]
end
