#output "sushil" {
#  value = "${aws_instance.nextgen_resources.id}"
#}

output "public_ip" {
  value = "${aws_instance.nextgen_resources.public_ip}"
}

output "private_ip" {
  value = "${aws_instance.nextgen_resources.private_ip}"
}

