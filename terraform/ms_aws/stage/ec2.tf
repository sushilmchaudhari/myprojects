provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.aws_region}"
}

module "staging_web" {
  source = "../modules/network"
  instance_count = 1
  subnet_id = "subnet-e46c97bf"
  instance_type = "t2.small"
  sg_name = "nextgen_proxy_security_group"
  az_id = "us-west-1c"
  is_eip = 1
  app_name = "staging_proxy"
  env_name = "staging"
}	

module "staging_app" {
  source = "../modules/network"
  instance_count = 1
  subnet_id = "subnet-9e619ac5"
  instance_type = "c4.xlarge"
  sg_name = "nextgen_staging_app_security_group"
  az_id = "us-west-1c"
  is_eip = 0
  app_name = "staging_app"
  env_name = "staging"
}

module "staging_db" {
  source = "../modules/network"
  instance_count = 1
  subnet_id = "subnet-a86398f3"
  instance_type = "m4.large"
  sg_name = "nextgen_staging_db_security_group"
  az_id = "us-west-1c"
  is_eip = 0
  app_name = "staging_db"
  env_name = "staging"
}

module "staging_backend" {
  source = "../modules/network"
  instance_count = 1
  subnet_id = "subnet-a86398f3"
  instance_type = "m4.large"
  sg_name = "nextgen_staging_support_security_group"
  az_id = "us-west-1c"
  is_eip = 0
  app_name = "staging_support"
  env_name = "staging"
}

