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

class oracleclient (
	$uname=$ebasetup::params::uname,
	$ora_basic=$ebasetup::params::ora_basic,
        $ora_sdk=$ebasetup::params::ora_sdk,
        $ora_sqlplus=$ebasetup::params::ora_sqlplus ) inherits ebasetup::params {

# Unzip instantclient-basic first, move to /opt/oracle (should add a folder - something like /opt/oracle/instantclient_X_X/)

        file { '/opt/oracle':
           ensure => directory,
           owner => "$uname",
        }

        exec { 'unzip_instantclient_basic':
           command => "/usr/bin/yes 'y' | /usr/bin/unzip $ora_basic -d /opt/oracle/",
#	   user => "${uname}",
           creates => '/opt/oracle/instantclient_12_1',    
	   require => File['/opt/oracle'],
        }

# Unzip instantclient-sdk and move its contents to folder created 

        exec { 'unzip_instantclient_sdk':
           command => "/usr/bin/yes 'y' | /usr/bin/unzip /tmp/basic1.zip -d /opt/oracle/",
#	   user => "${uname}",
	   creates => '/opt/oracle/instantclient_12_1/sdk',
           require => Exec['unzip_instantclient_basic'],
        }

# Unzip instantclient-sqlplus and move its contents to same folder

        exec { 'unzip_instantclient_sqlplus':
           command => "/usr/bin/yes 'y' | /usr/bin/unzip $ora_sqlplus -d /opt/oracle/",
#	   user => "${uname}",
	   creates => '/opt/oracle/instantclient_12_1/sqlplus',
           require => Exec['unzip_instantclient_sdk'],
        }


# Create Symbolic link	

	file { '/opt/oracle/instantclient_12_1/libclntsh.so':
           ensure => 'link',
           owner => "${uname}",
	   target => 'libclntsh.so.12.1',
	   require => Exec['unzip_instantclient_basic'],
	}

# Set Environment Variables
	
	file {'.bash_profile':
           ensure => 'present',
	   owner => "${uname}",
           mode => '0644',
           path => "/home/${uname}/.bash_profile",
	}	

	file_line { 'add_profile':
  	   path => "/home/$uname/.bash_profile",
  	   line => 'export LD_LIBRARY_PATH=/opt/oracle/instantclient_12_1',
	   require => File['.bash_profile']
	}

        file_line { 'oracle_env_pass':
           path => "/home/$uname/.bash_profile",
           line => 'export ORACLE_SYSTEM_PASSWORD=standard1',
           require => File['.bash_profile']
        }

}
