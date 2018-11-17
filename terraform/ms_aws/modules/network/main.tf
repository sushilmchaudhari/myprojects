data "aws_security_group" "secgroup" {

  filter {
    name   = "group-name"
    values = ["${var.sg_name}"]
  }

  filter {
    name   = "vpc-id"
    values = ["${var.vpc_id}"]
  }
}


resource "aws_instance" "nextgen_resources" {
  count = "${var.instance_count}"
  ami           = "${var.aws_ami}"
  instance_type = "${var.instance_type}"
  vpc_security_group_ids = ["${data.aws_security_group.secgroup.id}", "sg-920d24f4"]
  subnet_id = "${var.subnet_id}"
  key_name = "${var.key_name}"
  availability_zone = "${var.az_id}"
  associate_public_ip_address = "${ var.is_eip ? 1 : 0 }"

  ebs_block_device {
    device_name           = "/dev/xvdi"
    volume_type           = "gp2"
    volume_size           = 30
    delete_on_termination = true
  }

  volume_tags {
    Name = "nextgen_${var.app_name}"
  }

  user_data = "${file("attach_ebs.sh")}"

  tags {
        Name = "nextgen_${var.app_name}"
        environment = "${var.env_name}"
  }

}
