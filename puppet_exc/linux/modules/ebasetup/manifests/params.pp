class ebasetup::params {
  
  $uname = "${::cur_user}"
  $homedir = "/home/$uname"
  $eba_path = "$homedir/eba"
  $intake_path = "$homedir/eba_intake"
  $ora_basic = "$homedir/test-linux-setup/files/instantclient-basic-linux.x64-12.1.0.2.0.zip"
  $ora_sdk = "$homedir/test-linux-setup/files/instantclient-sdk-linux.x64-12.1.0.2.0.zip"
  $ora_sqlplus = "$homedir/test-linux-setup/files/instantclient-sqlplus-linux.x64-12.1.0.2.0.zip"
  $wmq_file = "$homedir/test-linux-setup/files/mqc80_8.0.0.1_linuxx86-64.tar.gz"
}

