#
# Cookbook:: proxy
# Recipe:: source
# Copyright:: 2018, The Authors, All Rights Reserved.
#

raise "#{node['platform']} is not a supported platform in the proxy::source recipe" unless platform_family?('rhel', 'amazon', 'fedora', 'debian', 'suse')

node.normal['nginx']['binary'] = node['nginx']['source']['sbin_path']
node.normal['nginx']['source']['version'] = node['nginx']['version']

user node['nginx']['user'] do
  system true
  shell  '/bin/false'
  home   '/var/www'
end

include_recipe 'proxy::commons_dir'
include_recipe 'proxy::commons_script'
include_recipe 'build-essential::default'

src_filepath = "#{Chef::Config['file_cache_path']}/nginx-#{node['nginx']['source']['version']}.tar.gz"

log src_filepath

# install prereqs
package value_for_platform_family(
  %w(debian) => %w(libpcre3 libpcre3-dev libssl-dev tar)
)

remote_file 'nginx source' do
  source   node['nginx']['source']['url']
  path     src_filepath
  backup   false
  retries  4
end

node.run_state['nginx_configure_flags'] = node['nginx']['source']['default_configure_flags'] | node['nginx']['configure_flags']


# Unpack downloaded source so we could apply nginx patches
bash 'unarchive_source' do
  cwd  ::File.dirname(src_filepath)
  code <<-EOH
    tar zxf #{::File.basename(src_filepath)} -C #{::File.dirname(src_filepath)} --no-same-owner
  EOH
  not_if { ::File.directory?("#{Chef::Config['file_cache_path'] || '/tmp'}/nginx-#{node['nginx']['source']['version']}") }
end


current_version = `"#{node['nginx']['dir']}"/sbin/nginx -v 2>&1 | awk -F/ '{print $2}'`
current_version = current_version.chomp

bash 'compile_nginx_source' do
  cwd  ::File.dirname(src_filepath)
  environment node.run_state['nginx_source_env']
  code <<-EOH
    cd nginx-#{node['nginx']['source']['version']} &&
    ./configure #{node.run_state['nginx_configure_flags'].join(' ')} &&
    make && make install
  EOH

  not_if do 
	 current_version == node['nginx']['source']['version']
         end
end


include_recipe 'proxy::commons_conf'

# Nginx Service

service "nginx" do
  service_name "nginx"
#  enabled true
#  running true
  reload_command "if [ -e #{node['nginx']['dir']}/logs/nginx.pid ]; then #{node['nginx']['dir']}/sbin/nginx -s reload; fi"
  start_command "#{node['nginx']['dir']}/sbin/nginx"
  stop_command "if [ -e #{node['nginx']['dir']}/logs/nginx.pid ]; then #{node['nginx']['dir']}/sbin/nginx -s stop; fi"
  status_command "curl http://localhost/nginx_status"
  supports [ :start, :stop, :reload, :status ]
  action [ :start ]
  pattern "nginx: master"
end


node.run_state.delete('nginx_configure_flags')
node.run_state.delete('nginx_force_recompile')
