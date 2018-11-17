#
# Cookbook:: proxy
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.


hostname "proxy.msri.org"

include_recipe "proxy::source"

logrotate_app 'nginx' do
  path      ['/var/log/nginx/*.log', '/opt/nginx/logs/*.log']
  options   ['missingok', 'compress', 'delaycompress', 'notifempty']
  frequency 'daily'
  rotate    52
  create    '644 root root'
  sharedscripts	true
  postrotate '[ ! -f /opt/nginx/logs/nginx.pid ] || kill -USR1 `cat /opt/nginx/logs/nginx.pid`'
end

include_recipe "m_newrelic::default"
