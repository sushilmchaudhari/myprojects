
# Passenger and Nginx 
default['rails']['root'] = '/opt/msri/apps/'
default['rails']['deploy']['dir'] = 'www'
default['rails']['environment'] = 'production'

# Paperclip links
default['paperclip']['links'] = ['cms', 'galleries', 'institutions', 'people', 'programs', 'summer_schools', 'videos', 'workshops']

# SSMTP 
default['ssmtp']['mailhub_name'] = 'sendmail.msri.org'
default['ssmtp']['hostname'] = 'www.msri.org'
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

