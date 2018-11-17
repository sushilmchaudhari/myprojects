provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.aws_region}"
}

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

resource "aws_instance" "nextgen_instances" {
  count = "${var.instance_count}"
  ami           = "${var.aws_ami}"
  instance_type = "${var.instance_type}"
  vpc_security_group_ids = ["${data.aws_security_group.secgroup.id}", "sg-920d24f4"]
  subnet_id = "${var.subnet_id}"
  key_name = "${var.key_name}" 
  availability_zone = "${var.az_id}"
  associate_public_ip_address = "${ var.is_eip ? 1 : 0 }"

  ebs_block_device {
	device_name = "/dev/xvdi"
	delete_on_termination = 1
	volume_size = 20 
  }


  provisioner "file" {
    source      = "provision.sh"
    destination = "/tmp/provision.sh"

    connection {
      bastion_host = "52.53.172.202"
      bastion_user = "ubuntu"
      bastion_private_key = "${file("~/.ssh/id_rsa")}"

      type = "ssh"
      user = "ubuntu"
      private_key = "${file("~/.ssh/id_rsa")}"
      host = "${aws_instance.nextgen_instances.private_ip}"
    }

  }

  provisioner "remote-exec" {
    inline = [
     "sudo chmod +x /tmp/provision.sh",
     "sudo sh /tmp/provision.sh",
    ]

    connection {
      type     = "ssh"
      user = "ubuntu"
      private_key = "${file("~/.ssh/id_rsa")}"
      bastion_host = "52.53.172.202"
      bastion_user = "ubuntu"
      bastion_private_key = "${file("~/.ssh/id_rsa")}"

    }

  }

  volume_tags {
    Name = "nextgen_${var.app_name}"
  }

  tags {
   	Name = "nextgen-${var.app_name}-${count.index}"
  }
}	

