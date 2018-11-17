
# Passenger and Nginx 
default['rails']['root'] = '/var/msri_cms/public'
default['rails']['environment'] = 'production'
default['server']['hostname'] = 'locomotive.msri.org'


# Mongo DB Attributes
default['mongodb']['repo'] = 'http://repo.mongodb.org/apt/ubuntu'
default['mongodb']['package_version'] = '3.2.18'
default['mongodb']['package_name'] = 'mongodb-org'



# SSMTP 
default['ssmtp']['mailhub_name'] = 'sendmail.msri.org'
default['ssmtp']['hostname'] = 'locomotive.staging.msri.org'
default['ssmtp']['rewrite_domain'] = 'msri.org'
default['ssmtp']['from_line_override'] = true
default['ssmtp']['root'] = 'systems@msri.org'

# Redis-server
default[:redis][:data_dir]          = '/var/lib/redis'
default[:redis][:deamon]	    = 'yes'
default[:redis][:db_basename]       = 'dump.rdb'
default[:redis][:server][:addr]     = '127.0.0.1'
default[:redis][:server][:port]     = '6379'
default[:redis][:server][:timeout]  = '300'

