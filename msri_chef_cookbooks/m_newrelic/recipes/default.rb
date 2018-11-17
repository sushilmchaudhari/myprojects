#
# Cookbook:: m_newrelic
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

# Add license info.
file "#{node['newrelic_infra']['license']['file']}" do
   content "license_key: #{node['newrelic_infra']['license_key']}"
   mode 0644
   owner node['newrelic_infra']['user']['name']
   group node['newrelic_infra']['group']['name']
end

# Add GPG key to apt repository
apt_repository 'newrelic_infra' do
   uri node['newrelic_infra']['apt']['uri']
   key node['newrelic_infra']['apt']['key']
   distribution node['newrelic_infra']['apt']['distribution']
   components node['newrelic_infra']['apt']['components']
   arch node['newrelic_infra']['apt']['arch']
   action node['newrelic_infra']['apt']['action']
end

# Run apt-get update
execute "apt-get-update" do
  command "apt-get update"
  ignore_failure true
end

# Install the newrelic-infra agent
package 'newrelic-infra' do
  action node['newrelic_infra']['packages']['agent']['action']
  retries node['newrelic_infra']['packages']['agent']['retries']
  version node['newrelic_infra']['packages']['agent']['version'].to_s
end

# Create and manage the agent directory
directory node['newrelic_infra']['agent']['directory']['path'] do
  owner node['newrelic_infra']['user']['name']
  group node['newrelic_infra']['group']['name']
  mode '0755'
end

# Enable and restart service
service 'newrelic-infra' do
   action [ :enable, :restart ]
end
