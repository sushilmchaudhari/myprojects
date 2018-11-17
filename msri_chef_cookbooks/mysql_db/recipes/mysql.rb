#
# Cookbook:: database
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

apt_package 'libaio1' do
  action :install
end

group 'Install mysql group' do
  group_name 'mysql'
  action :create
end

user 'Install mysql User' do
  username 'mysql'
  gid 'mysql'
  shell '/bin/false'
  system true
  manage_home false
  action :create
end

if "#{node['mysql']['version']}" =~ /5.5/
  remote_file "/tmp/mysql-#{node['mysql']['version']}.tar.gz" do
    source 'https://downloads.mysql.com/archives/get/file/mysql-5.5.54-linux2.6-x86_64.tar.gz'
    action :create_if_missing
  end
end

if "#{node['mysql']['version']}" =~ /5.6/
  remote_file "/tmp/mysql-#{node['mysql']['version']}.tar.gz" do
    source 'https://dev.mysql.com/get/Downloads/MySQL-5.6/mysql-5.6.38-linux-glibc2.12-x86_64.tar.gz'
    action :create_if_missing
  end
end

if node['mysql']['version'] == '5.5.54'
  bash "Install_mysql_from_source" do
    code <<-EOH
      cd /usr/local/
      tar zxf /tmp/mysql-#{node['mysql']['version']}.tar.gz
      ln -s mysql-5.5.54-linux2.6-x86_64 mysql
      cd mysql
      chown -R mysql .
      chgrp -R mysql .
      scripts/mysql_install_db --user=mysql
      chown -R mysql data
      cp support-files/mysql.server /etc/init.d/mysql.server
      /usr/sbin/update-rc.d mysql.server defaults 95
    EOH
    not_if "test -f /usr/local/mysql/bin/mysql"
  end
end

if node['mysql']['version'] == '5.6.38'
  bash "Install_mysql_from_source" do
    code <<-EOH
      cd /usr/local/
      tar zxf /tmp/mysql-#{node['mysql']['version']}.tar.gz
      ln -s mysql-5.6.38-linux-glibc2.12-x86_64 mysql
      cd mysql
      chown -R mysql .
      chgrp -R mysql .
      scripts/mysql_install_db --user=mysql
      chown -R mysql data
      cp support-files/mysql.server /etc/init.d/mysql.server
      /usr/sbin/update-rc.d mysql.server defaults 95
    EOH
    not_if "test -f /usr/local/mysql/bin/mysql"
  end
end

cookbook_file '/etc/my.cnf' do
  source 'my.cnf'
  owner 'root'
  group 'root'
  mode '0644'
  action :create
end

directory '/var/log/mysql' do
  owner 'mysql'
  group 'mysql'
  mode '0755'
  action :create
end

file '/var/log/mysql/mysql-error.log' do
  owner 'mysql'
  group 'mysql'
  mode '0755'
  action :create
end

service 'mysql.server' do
  action :start
  start_command "/etc/init.d/mysql.server start"
end

bash 'reset root passowrd first time' do
  sensitive true
  code <<-EOF
  echo "Reseting Root Password"
  /usr/local/mysql/bin/mysqladmin -u root password #{node[:mysql][:root][:passwd]}
  EOF
  ignore_failure true
end

bash 'reset root passowrd if already set' do
  code <<-EOF
  echo "Reseting Root Password"
  /usr/local/mysql/bin/mysqladmin -u root -p#{node[:mysql][:root][:passwd]} password #{node[:mysql][:root][:passwd]}
  EOF
end

