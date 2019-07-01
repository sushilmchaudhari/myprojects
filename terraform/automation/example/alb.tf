
module "main-alb" {
  source = "../modules/loadbalancer/"

  name = "${var.name}"
  tags = "${var.tags}"

  vpc_id          = "${module.main-vpc.vpc_id}"
  security_groups = "${module.main-sg.lb_security_group_id}"
  subnets         = "${module.main-vpc.lb_subnet_ids}"

  enable_https    = "${var.enable_https}"

  cert_crt_file_path = "${var.cert_crt_file_path}"
  cert_key_file_path = "${var.cert_key_file_path}"
  cert_chain_file_path = "${var.cert_chain_file_path}"


  http_target_group   = {
      name = "http-target-group-1",
      backend_protocol = "HTTP",
      backend_port = 80
    }

  https_target_group   = {
      name = "https-target-group-1",
      backend_port = 443,
      backend_protocol = "HTTPS"
    }

  http_tcp_listeners = [
    {
      port = 80,
      protocol = "HTTP"
    }
  ]

  https_listeners = [
    {
      port = 443,
      protocol = "HTTPS"
    }
  ]

  target_ids = "${module.app-ec2.instance_ids}"
}
