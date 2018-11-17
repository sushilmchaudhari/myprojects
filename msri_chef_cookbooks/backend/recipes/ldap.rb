
include_recipe 'openldap::default'

cookbook_file '/tmp/db.ldif' do
  source 'db.ldif' 
  owner 'root'
  group 'root'
  mode '0644'
  action :create_if_missing
  notifies :run, 'execute[create_db]'
end

execute 'create_db' do
  command "ldapadd -x -D cn=#{node['openldap']['cn']},#{node['openldap']['basedn']} -w #{node['openldap']['passwd']} -H ldapi:/// -f /tmp/db.ldif"
  action :nothing
end
