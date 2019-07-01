output "mgt_security_group_id" {
  description = "The ID of the Management Security Group"
  value       = "${aws_security_group.mgt.*.id}"
}

output "lb_security_group_id" {
  description = "The ID of the LB Security Group"
  value       = "${aws_security_group.lb.*.id}"
}

output "app_security_group_id" {
  description = "The ID of the APP Security Group"
  value       = "${aws_security_group.app.*.id}"
}

output "rds_security_group_id" {
  description = "The ID of the RDS Security Group"
  value       = "${aws_security_group.rds.*.id}"
}

output "ec_security_group_id" {
  description = "The ID of the ElastiCache Security Group"
  value       = "${aws_security_group.ec.*.id}"
}

output "worker_security_group_id" {
  description = "The ID of the Worker instance Security Group"
  value       = "${aws_security_group.worker.*.id}"
}
