#
# Cookbook:: webserver
# Recipe:: support
#
# Copyright:: 2017, The Authors, All Rights Reserved.


# Logrotate configuration
logrotate_app 'nginx' do
  path      ['/var/log/nginx/*.log', '/opt/nginx/logs/*.log']
  options   ['missingok', 'compress', 'delaycompress', 'notifempty']
  frequency 'daily'
  rotate    52
  create    '644 root root'
  sharedscripts true
  postrotate '[ ! -f /opt/nginx/logs/nginx.pid ] || kill -USR1 `cat /opt/nginx/logs/nginx.pid`'
end


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

