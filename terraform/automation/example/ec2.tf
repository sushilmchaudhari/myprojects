
resource "aws_key_pair" "key_pair" {
  count = "${var.create_new_key_pair ? 1 : 0 }"
  key_name   = "${var.ssh_key_pair_name}"
  public_key = "${file(var.ssh_key_filename)}"
}

module "app-ec2" {
  source = "../modules/instances/"

  instance_count = "${var.app_instance_count}"
  ami = "${var.app_ami}"
  instance_type = "${var.app_instance_type}"
  subnet_ids = ["${module.main-vpc.app_subnet_ids}"]
  az_ids = "${module.main-vpc.azs}"

  vpc_security_group_ids = ["${module.main-sg.app_security_group_id}"]

  iam_instance_profile = "${aws_iam_instance_profile.ec2_monitoring_profile.name}"

  required_data_partition = "${var.required_data_partition}"

  required_fixed_public_ip = false

  associate_public_ip_address = false
  disable_api_termination = false
  instance_initiated_shutdown_behavior = "stop"

  name = "${var.name}"

  ec2_suffix = "${var.app_instance_suffix}"

  root_volume_size = "${var.app_root_volume_size}"
  data_volume_size = "${var.app_data_volume_size}"

  key_pair_name = "${var.create_new_key_pair ? element(concat(aws_key_pair.key_pair.*.key_name, list("")),0) : var.key_pair_existing}"

  tags = "${var.tags}"

}

# Worker Instances
module "worker-ec2" {
  source = "../modules/instances/"

  instance_count = "${var.worker_instance_count}"
  ami = "${var.worker_ami}"
  instance_type = "${var.worker_instance_type}"
  subnet_ids = ["${module.main-vpc.worker_subnet_ids}"]
  az_ids = "${module.main-vpc.azs}"

  vpc_security_group_ids = ["${module.main-sg.worker_security_group_id}"]

  iam_instance_profile = "${aws_iam_instance_profile.ec2_monitoring_profile.name}"

  required_data_partition = "${var.required_data_partition}"

  required_fixed_public_ip = false

  associate_public_ip_address = false
  disable_api_termination = false
  instance_initiated_shutdown_behavior = "stop"

  name = "${var.name}"

  ec2_suffix = "${var.worker_instance_suffix}"

  root_volume_size = "${var.worker_root_volume_size}"
  data_volume_size = "${var.worker_data_volume_size}"

  key_pair_name = "${var.create_new_key_pair ? element(concat(aws_key_pair.key_pair.*.key_name, list("")),0) : var.key_pair_existing}"

  tags = "${var.tags}"
}


# Management Instances
module "mgt-ec2" {
  source = "../modules/instances/"

  instance_count = "${var.mgt_instance_count}"
  ami = "${var.mgt_ami}"
  instance_type = "${var.mgt_instance_type}"
  subnet_ids = ["${module.main-vpc.mgt_subnet_ids}"]
  az_ids = "${module.main-vpc.azs}"

  vpc_security_group_ids = ["${module.main-sg.mgt_security_group_id}"]

  iam_instance_profile = "${aws_iam_instance_profile.ec2_monitoring_profile.name}"

  required_data_partition = "${var.required_data_partition}"

  required_fixed_public_ip = true

  associate_public_ip_address = true
  disable_api_termination = false
  instance_initiated_shutdown_behavior = "stop"

  name = "${var.name}"

  ec2_suffix = "${var.mgt_instance_suffix}"

  root_volume_size = "${var.mgt_root_volume_size}"
  data_volume_size = "${var.mgt_data_volume_size}"

  key_pair_name = "${var.create_new_key_pair ? element(concat(aws_key_pair.key_pair.*.key_name, list("")),0) : var.key_pair_existing}"

  tags = "${var.tags}"
}
