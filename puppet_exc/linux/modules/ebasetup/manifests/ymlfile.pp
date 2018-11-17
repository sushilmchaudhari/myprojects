class ebasetup::ymlfile(
	$uname=$ebasetup::params::uname,
	$eba_path=$ebasetup::params::eba_path,
	) inherits ebasetup::params {
        
	file { 'tmp':
                ensure => directory,
                path => "$eba_path/tmp",
                owner => "$uname",
                group => "$uname",
                mode => '0755',
        }

        file { [ "$eba_path/tmp/archive_benefits.amounts.yml", "$eba_path/tmp/benefits.amounts.yml", "$eba_path/tmp/clear_benefits.amounts.yml" ]:
                content => "--- []",
                owner => "${uname}",
        }

}
