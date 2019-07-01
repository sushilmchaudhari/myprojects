output "load_balancer_id" {
  description = "The ID and ARN of the load balancer we created."
  value       = "${aws_lb.application.id}"
}

output "lb_dns_name" {
  description = "The DNS name of the load balancer."
  value       = "${aws_lb.application.dns_name}"
}
