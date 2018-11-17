node 'default'{

	user { 'codetheory':
  		ensure     => 'present',
  		comment    => 'Codetheory',
  		gid    => '20',
  		groups     => ['_appserveradm', '_appserverusr', '_lpadmin', 'admin'],
  		home       => '/Users/codetheory',
  		iterations => '21881',
  		password   => '401e3aa796b3bfff2c8e929a003b727be1bd548aa0f0b0e131f0d11f3953162be210200a70872734a28be747a933e12e2458ffdcc60d209eab9e006a9f4042dc883148070e6e8ad05f4a5e5d44bd0ddfc9494482f0d16c9d5eb1de086183db1b89df9982d2856eeed431d65e03ff99177c3185aa61bc926b1a0020c49621ddd8',
  		salt       => '0c3cd42b97d0b0df45542fcb5961a2920f2fd6204aa151bf08d762d9dd44fd0c',
  		shell      => '/bin/bash',
  		uid        => '502',
	}

}






