output "Instance_ids" {
  value = ["${aws_instance.nextgen_instances.*.id}"]
}

output "public_ips" {
  value = ["${aws_instance.nextgen_instances.*.public_ip}"]
}

output "private_ips" {
  value = ["${aws_instance.nextgen_instances.*.private_ip}"]
}

