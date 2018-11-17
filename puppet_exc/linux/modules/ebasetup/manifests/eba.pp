# Class: ebasetup
# ===========================
#
# Full description of class ebasetup here.
# This class installs Ruby Version Manager. Once RVM is installed it installs Ruby 2.1.9 and Bundler for Eba setup.
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

class ebasetup::eba(
        $uname=$ebasetup::params::uname,
        $eba_path=$ebasetup::params::eba_path,
	$homedir=$ebasetup::params::homedir ) inherits ebasetup::params {
	
# Creating some yml files to eba tmp folder.
	
	class { ebasetup::ymlfile: }

#	rvm::system_user { "${cur_user}": }	

# Installing Ruby 2.1.9 

	rvm_system_ruby { 'ruby-2.1.9':
    	   ensure      => 'present',
#    	   default_use => true,
	   notify => Rvm_gemset['ruby-2.1.9@eba'],
#    	   build_opts  => ['--binary'];
	}

# Create a Gem Set for eba project.

	rvm_gemset {'ruby-2.1.9@eba':
    	   ensure  => present,
    	   require => Rvm_system_ruby['ruby-2.1.9'];
	}

# Finally, install Bundler:

	rvm_gem { 'ruby-2.1.9@eba/bundler':
    	   ensure  => latest,
    	   require => Rvm_gemset['ruby-2.1.9@eba'];
	}


# Install QT55

	package { 'qt5-qtwebkit-devel':
	   ensure => present,
	}


        file_line { 'add_path':
           path => "/$homedir/.bash_profile",
           line => 'PATH=$PATH:/usr/lib64/qt5/bin/ ; export PATH',
           require => Package['qt5-qtwebkit-devel'],
	}


# Installing all the Gems required for EBA project.


        exec { 'bundle_install':
#          user => "${uname}",
          cwd => "$eba_path",
	  command => "/bin/bash -l -c 'source ${homedir}/.bash_profile ; source /usr/local/rvm/scripts/rvm ; /usr/local/rvm/gems/ruby-2.1.9@eba/bin/bundle install'",
#	  logoutput => true,
	  timeout => 1800,
	  require => [ Rvm_gem['ruby-2.1.9@eba/bundler'],Class['ebasetup::ymlfile'] ],
        }
	  

# Migrate rails active records and Populate the database with seed

        exec { 'create_db':
#           user => "${uname}",
           cwd => "$eba_path",
           command => "/bin/bash -l -c 'source ${homedir}/.bash_profile ; source /usr/local/rvm/scripts/rvm ; /usr/local/rvm/rubies/ruby-2.1.9/bin/rake db:drop db:create'",
#           logoutput => true,
           timeout => 1800,
	   require => Exec['bundle_install'],
        }

        exec { 'migrate_db':
#           user => "${uname}",
           cwd => "$eba_path",
           command => "/bin/bash -l -c 'source ${homedir}/.bash_profile ; source /usr/local/rvm/scripts/rvm ; /usr/local/rvm/rubies/ruby-2.1.9/bin/rake db:migrate db:seed'",
#           logoutput => true,
	   timeout => 1800,
	   require => Exec['bundle_install'],
	}


# Start Solr.


       exec { 'start_solr':
           cwd => "$eba_path",
#	   user => "${uname}",
           command => "/bin/bash -l -c 'source ${homedir}/.bash_profile ; source /usr/local/rvm/scripts/rvm ; /usr/local/rvm/rubies/ruby-2.1.9/bin/rake sunspot:solr:start'",
#	   logoutput => true,
	   require => Exec['bundle_install'],
        }

}
