
# Mysql Version

# Versions are GA Releases. Currently we are using 5.5.54 so its a default versions. 
default['mysql']['version'] = '5.5.54'

# If you need mysql version 5.6 , uncomment below line and comment other versions.
#default['mysql']['version'] = '5.6.38'

# If needed mysql version 5.6, uncomment below line and comment rest versions.
#default['mysql']['version'] = '5.7.20'

default[:mysql][:root][:passwd] = 'msrinextgen'
