class ebasetup::wmq (
        $uname=$ebasetup::params::uname,
        $wmq_file=$ebasetup::params::wmq_file,
        $homedir=$ebasetup::params::homedir ) inherits ebasetup::params {
	
	
#	file { 'mqc.tar.gz':
#	     source => 'puppet:///modules/ebasetup/mqc80_8.0.0.1_linuxx86-64.tar.gz',
#	     owner => "${uname}",
#	     path => '/tmp/mqc.tar.gz',
#	}
 
	exec { 'extract_wmq': 
	     command =>	"tar -xzf $wmq_file",
 	     cwd => '/tmp',
             creates => '/tmp/mqc80_8.0.0.1_linuxx86-64',
  	     path => ['/usr/bin', '/usr/sbin',],
	}

	exec { 'license':
	     cwd => '/tmp/mqc80_8.0.0.1_linuxx86-64',
	     command => "yes '1' | sh mqlicense.sh",
	     path => ['/usr/bin', '/usr/sbin',],
	     require => Exec['extract_wmq'],
	     unless => '/usr/bin/test -r /opt/mqm/licenses/status.dat ',
	     logoutput => 'true',
	}

	package { 'MQSeriesRuntime-8.0.0-1.x86_64':
	     provider => rpm,
	     ensure => installed,
	     source => '/tmp/mqc80_8.0.0.1_linuxx86-64/MQSeriesRuntime-8.0.0-1.x86_64.rpm',
	     require => Exec['extract_wmq'],
	}

        package { 'MQSeriesClient-8.0.0-1.x86_64':
             provider => rpm,
             ensure => present,
             source => '/tmp/mqc80_8.0.0.1_linuxx86-64/MQSeriesClient-8.0.0-1.x86_64.rpm',
       	     require => Exec['extract_wmq'],
        }

        package { 'MQSeriesJava-8.0.0-1.x86_64':
             provider => rpm,
             ensure => present,
             source => '/tmp/mqc80_8.0.0.1_linuxx86-64/MQSeriesJava-8.0.0-1.x86_64.rpm',
	     require => Exec['extract_wmq'],
        }

        package { 'MQSeriesSDK-8.0.0-1.x86_64':
             provider => rpm,
             ensure => present,
             source => '/tmp/mqc80_8.0.0.1_linuxx86-64/MQSeriesSDK-8.0.0-1.x86_64.rpm',
             require => Exec['extract_wmq'],
	}
}
