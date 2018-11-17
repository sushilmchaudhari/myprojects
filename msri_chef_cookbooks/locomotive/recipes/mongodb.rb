#
# Cookbook:: locomotive
# Recipe:: mongodb
#
# Copyright:: 2018, The Authors, All Rights Reserved.

package_version_major = node['mongodb']['package_version'].to_f

apt_repository 'mongodb' do
    uri node['mongodb']['repo']
    distribution "#{node['lsb']['codename']}/mongodb-org/#{package_version_major}"
    components node['platform'] == 'ubuntu' ? ['multiverse'] : ['main']
    key "https://www.mongodb.org/static/pgp/server-#{package_version_major}.asc"
end

# Run apt-get update
execute "apt-get-update" do
  command "apt-get update"
  ignore_failure true
end

# Install Mongodb
package node['mongodb']['package_name'] do
  action :install
  version "#{node['mongodb']['package_version']}"
end

# Start And Enable mongod service

service 'mongod' do
  action [ :enable, :start ]
end

