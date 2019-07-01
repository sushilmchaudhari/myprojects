module "ec-redis-jobs" {
  source = "../modules/elasticache/"

  name = "${var.name}-jobs"
  tags = "${var.tags}"

  enable_cluster_mode = false

  number_of_clusters = "${var.redis_jobs_cluster_count}"

  cache_node_count = "${var.redis_jobs_node_count}"

  cache_node_type = "${var.redis_jobs_node_type}"

  auto_failover = true

  az_ids = "${module.main-vpc.azs}"
  engine_type = "redis"
  redis_version = "${var.redis_jobs_version}"
  redis_port = "${var.redis_jobs_port}"

  ec_subnet_group = "${module.main-vpc.ec_subnet_group}"
  ec_security_group = "${module.main-sg.ec_security_group_id}"

  enable_encryption = false
}


module "ec-redis-cache" {
  source = "../modules/elasticache/"

  name = "${var.name}-cache"
  tags = "${var.tags}"

  enable_cluster_mode = false

  number_of_clusters = "${var.redis_cache_cluster_count}"

  cache_node_count = "${var.redis_cache_node_count}"

  cache_node_type = "${var.redis_cache_node_type}"

  auto_failover = true

  az_ids = "${module.main-vpc.azs}"
  engine_type = "redis"
  redis_version = "${var.redis_cache_version}"
  redis_port = "${var.redis_cache_port}"

  ec_subnet_group = "${module.main-vpc.ec_subnet_group}"
  ec_security_group = "${module.main-sg.ec_security_group_id}"

  enable_encryption = false
}
