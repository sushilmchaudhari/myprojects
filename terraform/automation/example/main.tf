
module "main-vpc" {
  source = "../modules/vpc/"

  name = "${var.name}"
  cidr = "${var.vpc_cidr}"

  azs = ["${var.AWS_REGION}a", "${var.AWS_REGION}b"]

  # app_subnets = ["${ length(split(",", var.app_subnets)) > 1 ? split(",", var.app_subnets) : var.app_subnets}"]
  # worker_subnets = ["${length(split(",", var.worker_subnets)) > 1 ? split(",", var.worker_subnets) : var.worker_subnets}"]
  app_subnets = ["${split(",", var.app_subnets)}"]
  worker_subnets = ["${split(",", var.worker_subnets)}"]
  public_subnets  = ["${split(",", var.mgt_subnets)}"]
  lb_subnets = ["${split(",", var.lb_subnets)}"]
  rds_subnets  = ["${split(",", var.rds_subnets)}"]
  elasticache_subnets = ["${split(",", var.ec_subnets)}"]

  enable_nat_gateway = true
  single_nat_gateway = true

  # create_rds_subnet_route_table = true
  create_rds_subnet_group = true

  tags = "${var.tags}"

  enable_dns_hostnames = true
  enable_dns_support   = true

  # VPC endpoint for S3
  enable_s3_endpoint = false

}
