module "main-sg" {
  source = "../modules/security_group/"

  name = "${var.name}"
  tags_sg = "${var.tags}"

  create_sg = true
  # create_sg_rule = true

  vpc-id = "${module.main-vpc.vpc_id}"

    mgt_ingress_rules = [
      {
        cidr_blocks = "0.0.0.0/0,180.151.106.99/32"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        description = "Allow SSH connections from internet"
      },
    ]

    lb_ingress_rules = [
      {
        cidr_blocks = "0.0.0.0/0"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        description = "Allow HTTP connections from internet"
      },
      {
        cidr_blocks = "0.0.0.0/0"
        from_port = 443
        to_port = 443
        protocol = "tcp"
        description = "Allow HTTPS connections from internet"
      },
    ]

    app_ingress_rules = [
      {
        cidr_blocks = "${var.mgt_subnets}"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        description = "Allow SSH connections from Management Resources"
      },
      {
        cidr_blocks = "${var.lb_subnets}"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        description = "Allow HTTP connections from Load Balancer"
      },
      {
        cidr_blocks = "${var.lb_subnets}"
        from_port = 443
        to_port = 443
        protocol = "tcp"
        description = "Allow HTTPS connections from Load Balancer"
      },
    ]

    rds_ingress_rules = [
      {
        cidr_blocks = "${format("%s,%s,%s", var.app_subnets, var.mgt_subnets, var.worker_subnets)}"
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        description = "Allow mysql connections from Application, Management and Worker/Cron Resources"
      },
    ]


    ec_ingress_rules = [
      {
        cidr_blocks = "${format("%s,%s,%s", var.app_subnets, var.worker_subnets, var.mgt_subnets)}"
        from_port = 6379
        to_port = 6379
        protocol = "tcp"
        description = "Allow Redis connections from Application and Worker Resources"
      },
    ]

    worker_ingress_rules = [
      {
        cidr_blocks = "${var.mgt_subnets}"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        description = "Allow SSH connections from Management Resources"
      },
    ]
}
