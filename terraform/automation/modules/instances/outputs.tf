output "public_ip" {
  value = "${aws_instance.server.*.public_ip}"
}

output "instance_ids" {
  value = "${aws_instance.server.*.id}"
}

output "private_ips" {
  value = "${aws_instance.server.*.private_ip}"
}

output "instance_ids_cloudwatch" {
  value = "${aws_instance.server.*.id}"
}

output "eip" {
  value = "${aws_eip.pub_ip_fixed.*.public_ip}"
}
