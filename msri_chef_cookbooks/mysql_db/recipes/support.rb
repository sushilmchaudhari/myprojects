#
# Cookbook:: mysql_db
# Recipe:: support
#
# Copyright:: 2018, The Authors, All Rights Reserved.

# Install and Configure NewRelic
include_recipe "m_newrelic::default"

# Configure Logrotate
logrotate_app 'mysql-server' do
  path      ['/var/log/mysql.log', '/var/log/mysql/mysql.log', '/var/log/mysql/mysql-slow.log', '/var/log/mysql/error.log', '/var/log/mysql/mysql-error.log']
  options   ['missingok', 'compress', 'delaycompress', 'notifempty']
  frequency 'daily'
  rotate    7
  create    '644 root root'
  sharedscripts true
  postrotate <<-EOL
		test -x /usr/bin/mysqladmin || exit 0
		# If this fails, check debian.conf! 
		MYADMIN="/usr/bin/mysqladmin --defaults-file=/etc/mysql/debian.cnf"
		if [ -z "`$MYADMIN ping 2>/dev/null`" ]; then
		  # Really no mysqld or rather a missing debian-sys-maint user?
		  # If this occurs and is not a error please report a bug.
		  #if ps cax | grep -q mysqld; then
		  if killall -q -s0 -umysql mysqld; then
 		    exit 1
		  fi 
		else
		  $MYADMIN flush-logs
		fi
EOL
end

# Create DB Backup Directories
%w(/opt/backup/ /var/lib/automysqlbackup).each do |dir|
  directory dir do
    mode  '0755'
  end
end

# Copy automysqlbackup conf file to /etc/default/
cookbook_file '/etc/default/automysqlbackup' do
  source 'default_automysqlbackup'
  owner 'root'
  group 'root'
  mode '0400'
  action :create
end

# Copy automysqlbackup script
cookbook_file '/usr/sbin/automysqlbackup' do
  source 'sbin_automysqlbackup'
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

# Create cron.daily job
file '/etc/cron.daily/automysqlbackup' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
  content <<-EOL
#!/bin/sh
test -x /usr/sbin/automysqlbackup && /usr/sbin/automysqlbackup
EOL
end

file '/etc/cron.daily/automysqlbackup_sync' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
  content <<-EOL
#!/bin/sh
rsync -av /var/lib/automysqlbackup /opt/backup/ >> /opt/backup/automysqlbackup_sync.log 2>&1
EOL
end
