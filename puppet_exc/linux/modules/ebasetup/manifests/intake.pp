# Class: ebasetup
# ===========================
#
# Full description of class ebasetup here.
# This class installs Ruby Version Manager. Once RVM is installed it installs Ruby 2.3.1 and Bundler for Eba setup.
#
# Authors
# -------
#
# Sushil Chaudhari  <sushil@codetheory.io>
#
# Copyright
# ---------
#
# Copyright 2016 Your name here, unless otherwise noted.
#

class ebasetup::intake(
        $uname=$ebasetup::params::uname,
        $intake_path=$ebasetup::params::intake_path,
        $homedir=$ebasetup::params::homedir ) inherits ebasetup::params  {

	$as_root = "/usr/bin/sudo -u ${uname} -H bash -l -c"

#	rvm::system_user { "${cur_user}": }	

# Next up, install Ruby 2.3.1 

	rvm_system_ruby { 'ruby-2.3.1':
    	   ensure      => 'present',
    	   default_use => true,
	   notify => Rvm_gemset['ruby-2.3.1@eba_intake'],
#    	   build_opts  => ['--binary'];
	}

# Create a Gem Set for eba project.

	rvm_gemset {'ruby-2.3.1@eba_intake':
    	   ensure  => present,
    	   require => Rvm_system_ruby['ruby-2.3.1'];
	}

# Finally, install Bundler:

	rvm_gem { 'ruby-2.3.1@eba_intake/bundler':
    	   ensure  => latest,
    	   require => Rvm_gemset['ruby-2.3.1@eba_intake'];
	}


# Install, configure and start Redis.

	package { 'install_redis':
	   name => 'redis',
	   ensure => installed,
	}

	service { 'start_redis':
	   name => 'redis',
	   ensure => running,
	   enable => true,
	   provider => systemd,
	   require => Package['install_redis'],
	}

# Installing all the Gems required for EBA Intake project.


        exec { 'install_allgems':
#          user => "${uname}",
          cwd => "$intake_path",
	  command => "/bin/bash -l -c 'source ${homedir}/.bash_profile ; source /usr/local/rvm/scripts/rvm ; /usr/local/rvm/gems/ruby-2.3.1@eba_intake/bin/bundle install'",
#	  logoutput => true,
	  timeout => 1800,
	  require => Rvm_gem['ruby-2.3.1@eba_intake/bundler'],
        }
	  
# Migrate rails active records and Populate the database with seed

        exec { 'create_intake_db':
#           user => "${uname}",
           cwd => "$intake_path",
           command => "/bin/bash -l -c 'export HOME=$homedir ; source /usr/local/rvm/scripts/rvm ; /usr/local/rvm/rubies/ruby-2.3.1/bin/rake db:drop db:create'",
#	   command => "/bin/bash -l -c 'export HOME=$homedir  ; /usr/bin/env'",
           logoutput => true,
           timeout => 1800,
	   require => Exec['install_allgems'],
        }

        exec { 'migrate_intake_db':
#           user => "${uname}",
           cwd => "$intake_path",
           command => "/bin/bash -l -c 'export HOME=$homedir ; source /usr/local/rvm/scripts/rvm ; /usr/local/rvm/rubies/ruby-2.3.1/bin/rake db:migrate db:seed'",
#           logoutput => true,
	   timeout => 1800,
	   require => Exec['install_allgems'],
	}

}
