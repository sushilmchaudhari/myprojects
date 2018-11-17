#
# Cookbook:: locomotive 
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

node.normal['rvm']['update'] = false
node.normal[:rvm][:install][:rubies] = ['ruby-2.3.0']
node.normal[:rvm][:gemset] = ['locomotive_msri']

hostname "locomotive.msri.org"

include_recipe "rvm_ruby::install_rvm"

include_recipe "rvm_ruby::install_ruby"

include_recipe "pass_nginx"

template "#{node[:passenger][:production][:path]}/sites-available/locomotive.msri.org.conf" do
  source "locomotive_vhost.erb"
  owner "root"
  group "root"
  mode 0755
  variables(
    :server_hostname => "#{node['server']['hostname']}",
    :rails_root => "#{node['rails']['root']}",
    :rails_environment => "#{node['rails']['environment']}"
  )
end


# Install and Configure MongoDB
include_recipe "locomotive::mongodb"

# Install necessary packages
include_recipe "locomotive::support"

# Install NewRelic Infrastructure
include_recipe "m_newrelic::default"
