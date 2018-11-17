#
# Cookbook:: mysql_db
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

# Set Hostname to
hostname "db.msri.org"

# Install Mysql DB
include_recipe "mysql_db::mysql"

# Install and configure logrotate and DB backup script.
include_recipe "mysql_db::support"

# Install Mysql gem required to create databases and users
mysql2_chef_gem 'default' do
  action :install
end

# Mysql Connection
connection_params = {
  :username => 'root',
  :password => 'msrinextgen',
  :host => '127.0.0.1'
}

# Create DBs and users
mysql_database 'msri_nextgen_production' do
  connection connection_params
  action :create
end

mysql_database 'jira_production' do
  connection connection_params
  action :create
end

mysql_database 'confluence_production' do
  connection connection_params
  action :create
end

mysql_database 'msri2010' do
  connection connection_params
  action :create
end

mysql_database 'lportal' do
  connection connection_params
  action :create
end

mysql_database_user 'msrinextgen_prod' do
  connection connection_params
  password 'REHa[rHl<XIZ'
  database_name 'msri_nextgen_production'
  host 'web.msri.org'
  privileges [:all]
  action [:create, :grant]
end

mysql_database_user 'msrinextgen_prod' do
  connection connection_params
  password 'REHa[rHl<XIZ'
  database_name 'msri_nextgen_production'
  host 'index.production.msri.org'
  privileges [:all]
  action [:create, :grant]
end

mysql_database_user 'msrinextgen_prod' do
  connection connection_params
  password 'REHa[rHl<XIZ'
  database_name 'msri_nextgen_production'
  host 'wiki.msri.org'
  privileges [:all]
  action [:create, :grant]
end

mysql_database_user 'jira' do
  connection connection_params
  password 'pjOjQS58'
  database_name 'jira_production'
  host 'start.msri.org'
  privileges [:all]
  action [:create, :grant]
end

mysql_database_user 'jira' do
  connection connection_params
  password 'pjOjQS58'
  database_name 'confluence_production'
  host 'start.msri.org'
  privileges [:all]
  action [:create, :grant]
end

mysql_database_user 'l_msriportlet' do
  connection connection_params
  password 'l30ao.o#'
  database_name 'msri2010'
  host 'legacy.msri.org'
  privileges [:all]
  action [:create, :grant]
end

mysql_database_user 'l_liferayu' do
  connection connection_params
  password 'H^Zm87st'
  database_name 'lportal'
  host 'legacy.msri.org'
  privileges [:all]
  action [:create, :grant]
end

mysql_database_user 'liferayu' do
  connection connection_params
  password 'H^Zm87st'
  database_name 'lportal'
  host 'legacy.msri.org'
  privileges [:all]
  action [:create, :grant]
end

mysql_database_user 'l_webportlet' do
  connection connection_params
  password '0h(4zo%l'
  database_name 'msri2010'
  host 'legacy.msri.org'
  privileges [:all]
  action [:create, :grant]
end

mysql_database_user 'l_orgportlet' do
  connection connection_params
  password 'P{D^apl.'
  database_name 'msri2010'
  host 'legacy.msri.org'
  privileges [:all]
  action [:create, :grant]
end


mysql_database_user 'l_regportlet' do
  connection connection_params
  password 'e[>2rST]'
  database_name 'msri2010'
  host 'legacy.msri.org'
  privileges [:all]
  action [:create, :grant]
end


mysql_database_user 'l_socialcron' do
  connection connection_params
  password 'FBtwl115r'
  database_name 'msri2010'
  host 'legacy.msri.org'
  privileges [:all]
  action [:create, :grant]
end

# Restart Mysql Service
service 'mysql.server' do
  action [:restart]
  restart_command "/etc/init.d/mysql.server restart"
end 

