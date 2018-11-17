provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.aws_region}"
}

module "staging_web" {
  source = "../../modules/network"
  instance_count = 1
  subnet_id = "subnet-2a8f494d"
  instance_type = "t2.small"
  sg_name = "proxy_security_group"
  az_id = "us-west-1b"
  is_eip = 1
  app_name = "test_staging_proxy"
}	

module "staging_app" {
  source = "../../modules/network"
  instance_count = 1
  subnet_id = "subnet-648b4d03"
  instance_type = "c4.xlarge"
  sg_name = "nextgen_staging_app_security_group"
  az_id = "us-west-1b"
  is_eip = 0
  app_name = "staging_app"
}

module "staging_db" {
  source = "../../modules/network"
  instance_count = 1
  subnet_id = "subnet-57884e30"
  instance_type = "m4.large"
  sg_name = "nextgen_staging_db_security_group"
  az_id = "us-west-1b"
  is_eip = 0
  app_name = "staging_db"
}

module "staging_backend" {
  source = "../../modules/network"
  instance_count = 1
  subnet_id = "subnet-57884e30"
  instance_type = "m4.large"
  sg_name = "nextgen_staging_backend_security_group"
  az_id = "us-west-1b"
  is_eip = 0
  app_name = "staging_backend"
}

