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

class ebasetup {

	$uname = "${::cur_user}"
	$home = "/Users/${uname}"
	$as_root = "/usr/bin/sudo -u ${uname} -H bash -l -c"

        package { 'coreutils':
                ensure => installed,
                provider => brew,
        }

# Installing Java.

        file { 'javaosx.dmg':
                ensure => 'file',
                source => 'puppet:///modules/ebasetup/javaforosx.dmg',
                path => '/tmp/javaosx.dmg',
                mode => '0755'
        }

        package { 'javaforosx':
                ensure => installed,
                source => '/tmp/javaosx.dmg',
                provider => pkgdmg,
        }

# Copying some yml files to eba tmp folder.

	file { 'tmp':
		ensure => 'directory',
		path => "/Users/${uname}/eba/tmp",
		owner => "$uname",
		group => 'staff',
		mode => '0755',
	}

        file { 'archive_benefits.amounts.yml':
           path => "/Users/${uname}/eba/tmp/archive_benefits.amounts.yml",
           source => 'puppet:///modules/ebasetup/archive_benefits.amounts.yml',
           owner => "$uname",
        }

        file { 'benefits.amounts.yml':
           path => "/Users/${uname}/eba/tmp/benefits.amounts.yml",
           source => 'puppet:///modules/ebasetup/benefits.amounts.yml',
           owner => "$uname",
        }

        file { 'clear_benefits.amounts.yml':
           path => "/Users/${uname}/eba/tmp/clear_benefits.amounts.yml",
           source => 'puppet:///modules/ebasetup/clear_benefits.amounts.yml',
           owner => "$uname",
        }

# Now we can install RVM (note the dependency on the curl package):


	exec { 'install_rvm':
	   user => "root",
  	   command => "${as_root} '/usr/bin/curl -L https://get.rvm.io | bash -s stable'",
#  	   command => "${as_root} '/usr/bin/curl -L https://raw.githubusercontent.com/wayneeseguin/rvm/master/binscripts/rvm-installer | bash -s stable'",
           creates => "${home}/.rvm/bin/rvm",
	   logoutput => true,	
	}
	
#Next up, install Ruby 2.1.9 (note the dependency on our previous install_rvm command):

	exec { 'install_ruby':
	  # We run the rvm executable directly because the shell function assumes an
	  # interactive environment, in particular to display messages or ask questions.
 	  # The rvm executable is more suitable for automated installs.
	  #
	  
	  cwd => "${home}/eba/",
	  command => "${as_root} 'source ${home}/.rvm/scripts/rvm ; ${home}/.rvm/bin/rvm install 2.1.9 ; ${home}/.rvm/bin/rvm use 2.1.9'",
	  creates => "${home}/.rvm/bin/ruby",
	  logoutput => true,
	  require => Exec['install_rvm'],
	  timeout => 1800,
	}

# Finally, install Bundler:

        exec { 'install_bundler':
          cwd => "/${home}/eba/",
          command => "${as_root} '/usr/bin/gem install bundler'",
          creates => "${home}/.rvm/bin/bundle",
	  logoutput => true,
          require => Exec['install_ruby'],
	  timeout => 1800,
        }



# Install QT55

	package {'qt55':
	   ensure => present,
	   provider => brew,
	}

	exec {'symlinks':
#	   path => ['/usr/local/bin','/usr/bin/','/usr/sbin'],
	   command => "${as_root} '/usr/local/bin/brew link --force qt55'",
#	   user => "${uname}",
	   require => Package['qt55'],
	   logoutput => true,
	}


        exec { 'bundle_install':
          user => "${uname}",
          cwd => "${home}/eba/",
#          path => ["/Users/${uname}/.rvm/gems/ruby-2.1.9@eba/bin/"],
          command => "${as_root} 'source ${home}/.bash_profile ; source ${home}/.rvm/scripts/rvm ; /Users/${uname}/.rvm/gems/ruby-2.1.9@eba/bin/bundle install'",
	  logoutput => true,
	  timeout => 1800,
        }
	  

# Migrate rails active records and Populate the database with seed

        exec { 'create_db':
           user => "${uname}",
           cwd => "${home}/eba/",
           command => "${as_root} 'source ${home}/.bash_profile ; source ${home}/.rvm/scripts/rvm ; /Users/${uname}/.rvm/rubies/ruby-2.1.9/bin/rake db:drop db:create'",
           logoutput => true,
           timeout => 1800,
        }

        exec { 'migrate_db':
           user => "${uname}",
           cwd => "${home}/eba/",
           command => "${as_root} 'source ${home}/.bash_profile ; source ${home}/.rvm/scripts/rvm ; /Users/${uname}/.rvm/rubies/ruby-2.1.9/bin/rake db:migrate db:seed'",
           logoutput => true,
	   timeout => 1800,
	}

#        exec {'run_rails':
#           user => "${uname}",
#           cwd => "${home}/eba/",
#           command => "${as_root} 'source ${home}/.bash_profile ; source ${home}/.rvm/scripts/rvm ; /usr/bin/rails s'",
#	   logoutput => true,
#        }


# Start Solr.

       exec { 'start_solr':
           cwd => "${home}/eba/",
	   user => "${uname}",
           command => "${as_root} 'source ${home}/.bash_profile ; source ${home}/.rvm/scripts/rvm ; /Users/${uname}/.rvm/rubies/ruby-2.1.9/bin/rake sunspot:solr:start'",
	   logoutput => true,
        }



}
