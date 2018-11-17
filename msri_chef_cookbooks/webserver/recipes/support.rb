#
# Cookbook:: webserver
# Recipe:: support
#
# Copyright:: 2017, The Authors, All Rights Reserved.


cron 'cron entry for notify_signout' do
  minute '15'
  hour '0'
  user 'msri'
  command "wget --post-data 'dummy' --bind-address=127.0.0.1 http://www.msri.org/programs/notify_signout >> /opt/msri/apps/#{node['rails']['deploy']['dir']}/shared/log/notify_signout.crontab.log 2>&1"
end

cron 'cron entry for notify_exit_survey' do
  minute '15'
  hour '0'
  user 'msri'
  command "wget --post-data 'dummy' --bind-address=127.0.0.1 http://www.msri.org/programs/notify_exit_survey >> /opt/msri/apps/#{node['rails']['deploy']['dir']}/shared/log/notify_exit_survey.crontab.log 2>&1"
end


logrotate_app 'msri.www' do
  path      '/opt/msri/apps/*/shared/log/production.log'
  options   ['missingok', 'compress', 'delaycompress', 'notifempty']
  frequency 'daily'
  rotate    52
  create    '644 root root'
end

logrotate_app 'nginx' do
  path      ['/var/log/nginx/*.log', '/opt/nginx/logs/*.log']
  options   ['missingok', 'compress', 'delaycompress', 'notifempty']
  frequency 'daily'
  rotate    52
  create    '644 root root'
  sharedscripts true
  postrotate '[ ! -f /opt/nginx/logs/nginx.pid ] || kill -USR1 `cat /opt/nginx/logs/nginx.pid`'
end

# Install NewRelic Infra
include_recipe "m_newrelic::default"

# Install SSMTP 
package 'ssmtp'

template '/etc/ssmtp/ssmtp.conf' do
  source 'ssmtp.conf.erb'
  owner 'root'
  group 'root'
  mode 0644
end

# Install Redis

package 'redis-server'

template '/etc/redis/redis.conf' do
  source 'redis.conf.erb'
  owner 'root'
  group 'root'
  mode 0644
end

service 'redis-server' do
  action [ :enable, :stop, :restart ]
end

