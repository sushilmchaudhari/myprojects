#
# Cookbook:: webserver
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

node.normal['rvm']['update'] = false
node.normal[:rvm][:install][:rubies] = ['ruby-2.5.0']
node.normal[:rvm][:gemset] = ['sync_ldap', 'msri-rails5.0']
node.normal['nginx']['conf']['default'] = false

# Set hostname
hostname "helloweb.msri.org"

# Install necessary packages.
%w(imagemagick zip libmysqlclient-dev).each do |pkg|
  package pkg
end

# Create /etc/msri_nextgen Directory
directory "/etc/msri_nextgen" do
  mode      '0755'
  owner     'msri'
  group     'msri'
  action    :create
  recursive true
end

# Copy keys used in data encryption
cookbook_file '/tmp/msri_encrypt_keys.tar.gz' do
  source 'msri_encrypt_keys.tar.gz'
  mode '0755'
  action :create
end

execute 'Extract Encryption Keys' do
  command 'tar -xzvf /tmp/msri_encrypt_keys.tar.gz'
  cwd '/etc/msri_nextgen'
  not_if { File.exists?("/etc/msri_nextgen/msri_nextgen_production_v1.encrypted_key") }
end


# Create App directory Directory
directory "#{node['rails']['root']}/#{node['rails']['deploy']['dir']}" do
  mode      '0755'
  owner     'msri'
  group     'msri'
  action    :create
  recursive true
end

# Install RVM
include_recipe "rvm_ruby::install_rvm"

# Install Required Ruby version
include_recipe "rvm_ruby::install_ruby"

# Install Passenger and Nginx
include_recipe "pass_nginx"


# Copy Certificates.
cookbook_file '/tmp/msri_web_certs.tar.gz' do
  source 'msri_web_certs.tar.gz'
  mode '0755'
  action :create
end

execute 'Extract Encryption Keys' do
  command 'tar -xzvf /tmp/msri_web_certs.tar.gz'
  cwd '/opt/nginx/certs'
  not_if { File.exists?("/opt/nginx/certs/wwwmsriorg-2016-ev.pem") }
end

# Change Permissions
execute 'Change Permission of Encryption Keys' do
  command 'chmod 644 * && chown msri:msri *'
  cwd '/etc/msri_nextgen/'
end

execute 'Chnage Permissions of Nginx certificates' do
  command 'chmod 644 * && chown msri:msri *'
  cwd '/opt/nginx/certs'
end


# Virtual host configuration 
template "#{node[:passenger][:production][:path]}/sites-available/www.msrinextgen.org" do
  source "www_msrinextgen_org.erb"
  owner "root"
  group "root"
  mode 0755
  variables(
    :rails_root => "#{node['rails']['root']}",
    :rails_environment => "#{node['rails']['environment']}",
    :rails_deploy_dir => "#{node['rails']['deploy']['dir']}"
  )
end

template "#{node[:passenger][:production][:path]}/sites-available/ssl.www.msrinextgen.org" do
  source "ssl_www_msrinextgen_org.erb"
  owner "root"
  group "root"
  mode 0755
  variables(
    :rails_root => "#{node['rails']['root']}",
    :rails_environment => "#{node['rails']['environment']}",
    :rails_deploy_dir => "#{node['rails']['deploy']['dir']}"
  )
end

# Create Paperclip links
node['paperclip']['links'].each do |ruby|
  link "#{node['rails']['root']}/#{node['rails']['deploy']['dir']}/current/public/system/paperclip/#{ruby}" do
    to "#{node['rails']['root']}/#{node['rails']['deploy']['dir']}/shared/paperclip/#{ruby}"
    link_type :symbolic
    action :create
  end
end

# Sync_ldap configuration
include_recipe "webserver::sync_ldap"

# Install Support apps like Redis, sendmail configuration
include_recipe "webserver::support"

