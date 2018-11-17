# Openldap
node.default['openldap']['package_install_action'] = :install
node.override['openldap']['rootpw'] = '{SSHA}jXWBh5W5q5DTzTbsWzQwCKSdocNcxXd3'
node.override['openldap']['domainname'] = 'msri.org'
default['openldap']['basedn'] = "dc=#{node['openldap']['domainname'].split('.').join(',dc=')}"
default['openldap']['server'] = "directory.#{node['openldap']['domainname']}"
default['openldap']['passwd'] = "msrinextgen"

# Postfix
default[:postfix][:mynetworks] = '10.17.1.0/24 10.17.2.0/24 10.17.3.0/24 10.17.4.0/24 10.17.5.0/24 10.17.6.0/24 10.17.7.0/24'  #Space seperated subnet list
default['postfix']['relayhost']['smtp'] = 'email-smtp.us-west-2.amazonaws.com'
default['postfix']['relayhost']['port'] = '587'
default['postfix']['sasl']['smtp_sasl_user'] = 'AKIAIMSMUKFOVDUK3MPA'
default['postfix']['sasl']['smtp_sasl_passwd'] = 'ApugfuJQC9sdjWYOyaWYlYgCHoxUN1fQ5REtssWuVTUA'
default['postfix']['sasl_password_file'] = '/etc/postfix/sasl_password'


# Solr
default['solr']['version']  = '4.2.0'
default['solr']['url']      = "https://archive.apache.org/dist/lucene/solr/#{node['solr']['version']}/#{node['solr']['version'].split('.')[0].to_i < 4 ? 'apache-' : ''}solr-#{node['solr']['version']}.tgz"
default['solr']['checksum'] = '5ee861d7ae301c0f3fa1e96e4cb42469531d8f9188d477351404561b47e55d94'
default['solr']['data_dir'] = '/etc/solr'
default['solr']['dir']      = '/opt/solr'
default['solr']['port']     = '8983'
default['solr']['pid_file'] = '/var/run/solr.pid'
default['solr']['log_file'] = '/var/log/solr.log'
default['solr']['user']     = 'root'
default['solr']['group']    = 'root'
default['solr']['install_java'] = true
default['solr']['java_options'] = '-Xms128M -Xmx512M'
