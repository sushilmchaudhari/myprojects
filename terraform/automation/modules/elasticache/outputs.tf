output "redis_primary_endpoint" {
  description = "The address of the endpoint for the primary node in the replication group, if the cluster mode is disabled."
  value = "${aws_elasticache_replication_group.redis-cluster-disabled.*.primary_endpoint_address}"
}

output "cluster_nodes_endpoints" {
  description = "The identifiers of all the nodes that are part of this replication group."
  value = "${aws_elasticache_replication_group.redis-cluster-disabled.*.member_clusters}"
}

output "elasticache_id" {
  value = "${aws_elasticache_replication_group.redis-cluster-disabled.*.id}"
}

output "elasticache_member_clusters" {
  value = "${aws_elasticache_replication_group.redis-cluster-disabled.*.member_clusters}"
}

