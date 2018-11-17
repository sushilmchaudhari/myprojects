node 'default' {

	$uname = "${::cur_user}"

# Installing necessary packages.

        package { [ 'epel-release', 'libaio', 'unzip', 'nodejs', 'rubygems' ]:
           ensure => installed,
           provider => yum,
        }

# Configuring Oracle client. 

	include oracleclient

	#### Setup EBA Env ####
	
	include ebasetup
	
	Class['oracleclient'] -> Class['ebasetup']

}

