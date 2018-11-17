provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.aws_region}"
}


module "prod_web" {
  source = "../modules/network"
  instance_count = 1
  subnet_id = "subnet-89f247ee"
  instance_type = "t2.small"
  sg_name = "nextgen_proxy_security_group"
  az_id = "us-west-1a"
  is_eip = 1
  app_name = "prod_proxy"
  env_name = "prod"
}	

module "prod_app" {
  source = "../modules/network"
  instance_count = 1
  subnet_id = "subnet-f7f14490"
  instance_type = "c4.xlarge"
  sg_name = "nextgen_prod_app_security_group"
  az_id = "us-west-1a"
  is_eip = 0
  app_name = "prod_app"
  env_name = "prod"
}

module "prod_db" {
  source = "../modules/network"
  instance_count = 1
  subnet_id = "subnet-f8f1449f"
  instance_type = "m4.large"
  sg_name = "nextgen_prod_db_security_group"
  az_id = "us-west-1a"
  is_eip = 0
  app_name = "prod_db"
  env_name = "prod"
}

module "prod_backend" {
  source = "../modules/network"
  instance_count = 1
  subnet_id = "subnet-f8f1449f"
  instance_type = "m4.large"
  sg_name = "nextgen_prod_support_security_group"
  az_id = "us-west-1a"
  is_eip = 0
  app_name = "prod_support"
  env_name = "prod"
}

module "prod_legacy" {
  source = "../modules/network"
  instance_count = 1
  subnet_id = "subnet-62f04505"
  instance_type = "t2.small"
  sg_name = "nextgen_prod_app_security_group"
  az_id = "us-west-1a"
  is_eip = 0
  app_name = "prod_legacy"
  env_name = "prod"
}

module "prod_wiki" {
  source = "../modules/network"
  instance_count = 1
  subnet_id = "subnet-f7f14490"
  instance_type = "c4.xlarge"
  sg_name = "nextgen_prod_app_security_group"
  az_id = "us-west-1a"
  is_eip = 0
  app_name = "start"
  env_name = "prod"
}

