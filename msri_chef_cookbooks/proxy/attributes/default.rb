default['nginx']['dir'] = '/opt/nginx'
default['nginx']['user'] = 'www-data'
default['nginx']['log_dir'] = '/var/log/nginx'
default['nginx']['port'] = '80'
default['nginx']['server_name'] = 'localhost'
default['nginx']['version'] = '1.6.2'
default['nginx']['script_dir']   = '/usr/sbin'

#default['nginx']['source']['version'] = '1.6.2'
default['nginx']['source']['prefix']    = "/opt/nginx"
default['nginx']['source']['conf_path'] = "#{node['nginx']['dir']}/conf/nginx.conf"
default['nginx']['source']['sbin_path'] = "#{node['nginx']['source']['prefix']}/sbin/nginx"
default['nginx']['pidfile_location']	= "#{node['nginx']['dir']}/log/nginx.pid"

# Wno-error can be removed when nginx compiles on GCC7: https://trac.nginx.org/nginx/ticket/1259
default['nginx']['source']['default_configure_flags'] = %W(
  --prefix=#{node['nginx']['source']['prefix']}
  --conf-path=#{node['nginx']['dir']}/conf/nginx.conf
  --sbin-path=#{node['nginx']['source']['sbin_path']}
  --with-http_ssl_module 
  --with-http_gzip_static_module
  --with-cc-opt=-Wno-error
)

default['nginx']['configure_flags']    = []
default['nginx']['source']['version']  = node['nginx']['version']
default['nginx']['source']['url']      = "http://nginx.org/download/nginx-#{node['nginx']['version']}.tar.gz"
default['nginx']['source']['checksum'] = '8793bf426485a30f91021b6b945a9fd8a84d87d17b566562c3797aba8fac76fb'

