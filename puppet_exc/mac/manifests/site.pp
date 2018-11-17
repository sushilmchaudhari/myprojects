

node 'default' {

	$uname = "${::cur_user}"


        #### Configuring Oracle client on Mac which is accessbile on EBA VM. EBA uses Oracle DB. In Prod env we use Linux platform. But as Dev	      #### /tester/Devops we use mac machines in day to day working. We can not install oracle DB on Mac so we set up oracle client on Mac. 

	include oracleclient

	#### Setup EBA Env ####
	
	include ebasetup


}

