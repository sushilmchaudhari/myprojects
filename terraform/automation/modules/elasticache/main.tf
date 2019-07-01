locals {
  envi = "${lookup(var.tags, "Environment")}"
  random_str = "${random_id.server.dec}"
}

resource "random_id" "server" {
  byte_length = 2
}

resource "aws_elasticache_parameter_group" "redis_pgroup" {
  count = "${var.number_of_clusters}"
  name = "${format("%s-%s-redis-paramerter-group-%s-${count.index+1}", var.name, local.envi, local.random_str)}"

  description = "Terraform-managed ElastiCache Redis parameter group for ${var.name}-${local.envi}"

  # Striping version from redis_version var
  family    = "redis${replace(var.redis_version, "/\\.[\\d]+$/","")}"
  parameter = "${var.redis_parameters}"

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_elasticache_replication_group" "redis-cluster-disabled" {
  count = "${ var.enable_cluster_mode ? 0 : var.number_of_clusters}"

  replication_group_id          = "${format("%.20s","${var.name}-${local.envi}${count.index+1}")}"
  replication_group_description = "Terraform-managed ElastiCache Redis Cluster mode disabled for ${var.name}-${local.envi}"

  number_cache_clusters         = "${var.cache_node_count}"
  node_type                     = "${var.cache_node_type}"
  automatic_failover_enabled    = "${var.auto_failover}"
  availability_zones            = "${var.az_ids}"
  engine                        = "${var.engine_type}"
  engine_version                = "${var.redis_version}"
  parameter_group_name          = "${element(aws_elasticache_parameter_group.redis_pgroup.*.id, count.index)}"
  port                          = "${var.redis_port}"
  subnet_group_name             = "${var.ec_subnet_group}"
  security_group_ids            = ["${var.ec_security_group}"]

  maintenance_window            = "${var.maintenance_window}"

  notification_topic_arn        = "${var.notification_group_name}"

  snapshot_window               = "${var.backup_time}"
  snapshot_retention_limit      = "${var.backup_retention}"

  apply_immediately             = "${var.apply_modification}"

  auto_minor_version_upgrade    = "${var.auto_upgrade_minor_ver}"

  transit_encryption_enabled    = "${var.enable_encryption}"

  tags = "${merge(var.tags, map("Name", format("%s-%s-redis", var.name, local.envi)))}"

  lifecycle {
    ignore_changes = ["number_cache_clusters"]
  }
}
