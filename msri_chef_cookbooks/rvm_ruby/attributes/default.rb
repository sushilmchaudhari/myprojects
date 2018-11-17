# Attributes required to install RVM

default[:rvm][:path] = '/usr/local/rvm'
default[:rvm][:temp][:path] = '/tmp'
default[:rvm][:installer] = 'https://raw.githubusercontent.com/rvm/rvm/master/binscripts/rvm-installer'
default[:rvm][:gpg_keys] = '409B6B1796C275462A1703113804BB82D39DC0E3'
default[:rvm][:version] = 'stable'
default[:rvm][:update] = true

# Attributes required to install Ruby
default[:rvm][:install][:rubies] = ['ruby-2.5.0']
default[:rvm][:delete][:rubies] = []
default[:rvm][:gemset] = ['global']
default[:rvm][:ruby][:binaries] = ['erb', 'executable-hooks-uninstaller', 'gem', 'irb', 'rake', 'rdoc', 'ri', 'ruby', 'testrb', 'bundle', 'bundler']

