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

class ebasetup (
	$uname=$ebasetup::params::uname,
        $eba_path=$ebasetup::params::eba_path,
	$intake_path=$ebasetup::params::intake_path,
        $homedir=$ebasetup::params::homedir ) inherits ebasetup::params {

#	$uname = "${::cur_user}"

# Now we can install RVM (note the dependency on the curl package):

	class { '::rvm': } 

	file { "/home/$uname/.rvmrc":
	   content => 'umask u=rwx,g=rwx,o=rx ; export rvm_max_time_flag=20',
  	   mode    => '0664',
 	   before  => Class['rvm'],
	}	

#	rvm::system_user { "${cur_user}": }	

# Installaing foreman and creating foreman file to run all (Eba/Intake/Redis/Resuque) together.

#        package { [ 'foreman', 'subcontractor' ] :
#           provider => gem,
#           install_options => [ { '-i', "$intake_path" } ],
#        }

        $foreman_template = @(END)
           redis: redis-server
           intake: cd <%= @intake_path %> && bundle exec rails s -p 3000
           worker: bundle exec rake resque:work QUEUE=*
           eba: subcontract --rvm ruby-2.1.8@eba --chdir <%= @eba_path %> --signal INT -- rails s -p 3001
        END

        file { "$intake_path/Procfile":
           ensure  => file,
           content => inline_template($foreman_template),
         }


# Installing MQ client for Centos 7.

	class { ebasetup::wmq: }
	
# Configuring Eba project.

# 	class { ebasetup::eba: }

# Configuring Eba Intake project.

	class { ebasetup::intake: }

}

