
include_attribute 'rvm_ruby::default'

default['nginx']['conf']['default'] = true
default[:passenger][:production][:path] = '/opt/nginx'
default[:passenger][:under][:gemset]  = true            # Do not change this option
default[:passenger][:version] = '5.0.23'

default['rack']['version'] = '1.6.8'
default['passenger']['version'] = '5.0.23'

default['nginx']['log_dir'] = '/var/log/nginx'
