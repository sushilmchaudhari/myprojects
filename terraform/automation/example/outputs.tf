output "lb_dns_name" {
  description = "The DNS name of the load balancer."
  value       = "${module.main-alb.lb_dns_name}"
}

output "mgt_public_ip_address" {
  value = "${module.mgt-ec2.public_ip}"
}

output "mgt_static_public_ip_address" {
  value = "${module.mgt-ec2.eip}"
}

output "app_server_list" {
  value = "${module.app-ec2.private_ips}"
}

output "worker_server_list" {
  value = "${module.worker-ec2.private_ips}"
}

output "redis_jobs_endpoint" {
  description = "Redis resque job cluster endoint"
  value       = "${module.ec-redis-jobs.redis_primary_endpoint}"
}

output "redis_cache_endpoint" {
  description = "Redis cache cluster endoint"
  value       = "${module.ec-redis-cache.redis_primary_endpoint}"
}

output "db_master_endpoint" {
  description = "master RDS database endpoint"
  value       = "${module.master_db.db_host}"
}

output "db_replica_endpoint" {
  description = "Replica RDS database endpoint"
  value       = "${module.replica.db_host}"
}

output "cw_notification_group" {
  description = "CloudWatch Notification Topic/Group"
  value       = "${aws_sns_topic.alarm.id}"
}

output "mgt_static_public_ip_address" {
  value = "${module.mgt-ec2.eip}"
}
