variable "name" {
  description = "Name to be used on all resources as prefix"
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  default     = {}
}

variable "enable_cluster_mode" {
  description = "Enable cluster mode for Redis. Creates multiple shards for redis. If disabled, cluster has only 1 shard."
  default = "false"
}

variable "number_of_clusters" {
  description = "Number of clusters to create with number of cache_node_count"
  default = 1
}

variable "cache_node_count" {
  description = "The number of cache clusters (primary and replicas) this replication group will have. If Multi-AZ is enabled, the value of this parameter must be at least 2."
  # default = 2
}

variable "cache_node_type" {
  description = "The compute and memory capacity of the nodes in the node group"
  # default = "cache.t2.micro"
}

variable "auto_failover" {
  description = "Specifies whether a read-only replica will be automatically promoted to read/write primary if the existing primary fails."
  default = "true"
}

variable "az_ids" {
  description = "List of availability zone/s"
  type = "list"
  default = []
}

variable "engine_type" {
  description = "The name of the cache engine to be used for the clusters"
  default = "redis"
}

variable "redis_version" {
  description = "The version number of the cache engine to be used for the cache clusters. If not specified, uses latest redis version available"
  default     = ""
}


variable "redis_parameters" {
  type        = "list"
  description = "additional parameters modifyed in parameter group"
  default     = []
}

variable "redis_port" {
  description = "The port number on which each of the cache nodes will accept connections. for Redis the default port is 6379"
  default = 6379
}

variable "ec_subnet_group" {
  description = "The name of the subnet group to be used. This is created as a part of VPC module."
}

variable "ec_security_group" {
  type = "list"
  description = "One or more Amazon VPC security groups associated. This is created as a part of Security Group module."
}

variable "maintenance_window" {
  description = "Specifies the weekly time range for when maintenance on the cache cluster is performed. The format is ddd:hh24:mi-ddd:hh24:mi (24H Clock UTC). The minimum maintenance window is a 60 minute period. Example: sun:05:00-sun:09:00"
  default = ""
}

variable "notification_group_name" {
  description = "An Amazon Resource Name (ARN) of an SNS topic to send ElastiCache notifications to. Example: arn:aws:sns:us-east-1:012345678999:my_sns_topic"
  default = ""
}

variable "backup_time" {
  description = "The daily time range (in UTC) during which ElastiCache will begin taking a daily snapshot of cache cluster. The minimum snapshot window is a 60 minute period. Example: 05:00-09:00"
  default = ""
}

variable "backup_retention" {
  description = "The number of days for which ElastiCache will retain automatic cache cluster snapshots before deleting them."
  default = 0
}

variable "apply_modification" {
  description = "Specifies whether any modifications are applied immediately, or during the next maintenance window."
  default = "false"
}

variable "auto_upgrade_minor_ver" {
  description = "Specifies whether a minor engine upgrades will be applied automatically to the underlying Cache Cluster instances during the maintenance window."
  default = "false"
}

variable "enable_encryption" {
  description = "Whether to enable encryption in transit."
  default = "false"
}

variable "redis_password" {
  description = "The password used to access a password protected server. Can be specified only if transit_encryption_enabled = true. must contain from 16 to 128 alphanumeric characters or symbols (excluding @, double_quotes, and /)"
  default = "passwordforredis"
}


variable "replica_count_per_shard" {
  description = "Specify the number of replica nodes in each node group. Valid values are 0 to 5. Changing this number will force a new resource."
  default = 1
}

variable "shard_count" {
  description = "Specify the number of node groups (shards) for this Redis replication group. Changing this number will trigger an online resizing operation before other settings modifications"
  default = 1
}
