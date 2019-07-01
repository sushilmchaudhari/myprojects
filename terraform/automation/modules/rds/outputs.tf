output "db_instance_id" {
  value = "${element(aws_db_instance.db.*.id, 0)}"
}

output "db_host" {
  value = "${aws_db_instance.db.*.address}"
}
