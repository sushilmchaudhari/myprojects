# Class: oracleclient
# ===========================
#
# Downloads and Installs oracle client for Mac system. Oracle version is 12.1. 
#
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

class oracleclient {

	$uname = "${::cur_user}" 		# Specifies current user . It is a Custome fact defined.


# Unzip instantclient-basic first, move to /opt/oracle (should add a folder - something like /opt/oracle/instantclient_X_X/)

        file { '/opt/oracle':
           ensure => directory,
           owner => "$uname",
        }

        file { '/tmp/basic.zip':
           source => 'puppet:///modules/oracleclient/instantclient-basic-macos.x64-12.1.0.2.0.zip',
           owner => "$uname",
	   notify => Exec['unzip_instantclient_basic'],
        }

        exec { 'unzip_instantclient_basic':
           command => "/usr/bin/yes 'y' | /usr/bin/unzip /tmp/basic.zip -d /opt/oracle/",
	   user => "${uname}",
           creates => '/opt/oracle/instantclient_12_1',    
	   require => File['/opt/oracle'],
           refreshonly => true,
        }

# Unzip instantclient-sdk and move its contents to folder created 

        file { '/tmp/basic1.zip':
           source => 'puppet:///modules/oracleclient/instantclient-sdk-macos.x64-12.1.0.2.0.zip',
	   owner => "$uname",
	   notify => Exec['unzip_instantclient_sdk'],
        }

        exec { 'unzip_instantclient_sdk':
           command => "/usr/bin/yes 'y' | /usr/bin/unzip /tmp/basic1.zip -d /opt/oracle/",
	   user => "${uname}",
           require => Exec['unzip_instantclient_basic'],
           refreshonly => true,
        }

# Unzip instantclient-sqlplus and move its contents to same folder

        file { '/tmp/basic2.zip':
           source => 'puppet:///modules/oracleclient/instantclient-sqlplus-macos.x64-12.1.0.2.0.zip',
	   owner => "$uname",
	   notify => Exec['unzip_instantclient_sqlplus'],
        }

        exec { 'unzip_instantclient_sqlplus':
           command => "/usr/bin/yes 'y' | /usr/bin/unzip /tmp/basic2.zip -d /opt/oracle/",
	   user => "${uname}",
           require => Exec['unzip_instantclient_sdk'],
           refreshonly => true,
        }

# Create Symbolic link	

	file { '/opt/oracle/instantclient_12_1/libclntsh.dylib':
           ensure => 'link',
           owner => "${uname}",
	   target => 'libclntsh.dylib.12.1',
	   require => Exec['unzip_instantclient_basic'],
	}

# Set Environment Variables
	
	file {'.bash_profile':
           ensure => 'present',
	   owner => "${uname}",
           mode => '0644',
           path => "/Users/${uname}/.bash_profile",
	}	

	file_line { 'add_profile':
  	   path => "/Users/$uname/.bash_profile",
  	   line => 'export OCI_DIR=/opt/oracle/instantclient_12_1',
	   require => File['.bash_profile']
	}

	file_line { 'add_prfile_1':
 	   path => "/Users/$uname/.bash_profile",
	   line => 'export SQLPATH=/opt/oracle/instantclient_12_1',
	   require => File['.bash_profile']
	}	


	file_line { 'add_profile_2':
  	   path => "/Users/$uname/.bash_profile",
	   line => 'export ORACLE_HOME=/opt/oracle/instantclient_12_1',
	   require => File['.bash_profile']
	}

	file_line { 'add_prfile_3':
	   path => "/Users/$uname/.bash_profile",
	   line => 'export NLS_LANG=AMERICAN_AMERICA.UTF8',
	   require => File['.bash_profile']
	}	

        file_line { 'oracle_env_pass':
           path => "/Users/$uname/.bash_profile",
           line => 'export ORACLE_SYSTEM_PASSWORD=standard1',
           require => File['.bash_profile']
        }


# Source profile file.

#	exec { 'source_profile':
#	  command => "/bin/bash -c '/Users/${uname}/.bash_profile'", 
#	  user => "${uname}"
#	}

# Remove all tmp files

	exec { 'remove_files':
	  command => '/bin/rm -f /tmp/basic.zip /tmp/basic1.zip /tmp/basic2.zip'
	}
	


}
