# Default Options

variable "name" {
  description = "Mandatory - Name of the application"
  default = "evo"
}

variable "AWS_REGION" {
  description = "Mandatory - AWS region when resouces should be created"
  default = "us-east-1"
}

variable "tags" {
  description = "Mandatory - Name to be used on all resources as prefix"
  default = {
    Terraform   = "true"
    Environment = ""
  }
}

#### VPC VARIABLES #########

variable "vpc_cidr" {
  description = "CIDR for VPC"
  default = "10.0.0.0/16"
}

variable "app_subnets" {
  description = "CIDR for app subnets"
  default = "10.0.1.0/24,10.0.2.0/24"
}

variable "worker_subnets" {
  description = "CIDR for worker subnets"
  default = "10.0.10.0/24,10.0.11.0/24"
}

variable "rds_subnets" {
  description = "CIDR for rds subnets"
  default = "10.0.21.0/24,10.0.22.0/24"
}

variable "ec_subnets" {
  description = "CIDR for ec for redis subnets"
  default = "10.0.51.0/24,10.0.52.0/24"
}

variable "lb_subnets" {
  description = "CIDR for Load balancer subnets"
  default = "10.0.61.0/24,10.0.62.0/24"
}

variable "mgt_subnets" {
  description = "CIDR for mgt subnets"
  default = "10.0.91.0/24"
}

variable "associate_public_ip_address" {
  description = "If true, the EC2 instance will have associated public IP address"
  default     = false
}

variable "disable_api_termination" {
  description = "If true, enables EC2 Instance Termination Protection"
  default     = true
}

variable "instance_initiated_shutdown_behavior" {
  description = "Shutdown behavior for the instance"
  default     = "stop"
}

variable "create_new_key_pair" {
  description = "Create a new key for logging in to the instance. Allowed values true/false"
  default     = false
}

variable "ssh_key_filename" {
  description = "If create_new_key_pair is true, provide public key file."
  default = "~/.ssh/id_rsa.pub"
}

variable "key_pair_existing" {
  description = "If create_new_key_pair is false, provide existing key pair name here."
  default     = "key-pair-name-already-available"
}

variable "ssh_key_pair_name" {
  description = "If create_new_key_pair is true, provide new key pair name here."
  default = "new-key-pair-name"
}

# APP Instance Profile

variable "app_instance_count" {
  description = "Number of instances to launch"
  default     = 1
}

variable "app_ami" {
  description = "ID of AMI to use for the instance. Default is Ubuntu 18.04 Bionic amd64"
}

variable "app_instance_type" {
  description = "The type of instance to start"
  default = "t2.micro"
}

variable "app_instance_suffix" {
  description = "Suffix to append to instance name"
  default = "app"
}

variable "app_root_volume_size" {
  description = "Size of data partiton in GiB"
  default = "10"
}

variable "app_data_volume_size" {
  description = "Size of data partiton in GiB"
  default = "10"
}

# Worker Instance Profile

variable "worker_instance_count" {
  description = "Number of instances to launch"
  default     = 1
}

variable "worker_ami" {
  description = "ID of AMI to use for the instance. Default is Ubuntu 18.04 Bionic amd64"
}

variable "worker_instance_type" {
  description = "The type of instance to start"
  default = "t2.micro"
}

variable "worker_instance_suffix" {
  description = "Suffix to append to instance name"
  default = "worker"
}

variable "worker_root_volume_size" {
  description = "Size of data partiton in GiB"
  default = "10"
}

variable "worker_data_volume_size" {
  description = "Size of data partiton in GiB"
  default = "10"
}


# Managament Instance Profile

variable "mgt_instance_count" {
  description = "Number of instances to launch"
  default     = 1
}

variable "mgt_ami" {
  description = "ID of AMI to use for the instance. Default is Ubuntu 18.04 Bionic amd64"
}

variable "mgt_instance_type" {
  description = "The type of instance to start"
  default = "t2.micro"
}

variable "mgt_instance_suffix" {
  description = "Suffix to append to instance name"
  default = "mgt"
}

variable "mgt_root_volume_size" {
  description = "Size of data partiton in GiB"
  default = "10"
}

variable "mgt_data_volume_size" {
  description = "Size of data partiton in GiB"
  default = "10"
}

### DATABASE VARIABLES ###

variable "mysql_version" {
  description = "Mysql Version"
  default = "5.6.40"
}

variable "mysql_instance_type" {
  description = "Mysql instance type"
  default = "db.t2.large"
}

variable "mysql_storage" {
  description = "Mysql Instance Storage size"
  default = 5
}

variable "database_name" {
  description = "Database Name"
}

variable "database_user" {
  description = "Database user or admin user"
}

variable "database_passwd" {
  description = "Database user/admin user password"
}

variable "database_port" {
  description = "Mysql Port Number"
  default = "3306"
}

variable "master_db_identifier" {
  description = "Name of the database master instance to be created"
}

variable "replica_db_identifier" {
  description = "Name of the database replica instance to be created"
}


### REDIS JOBS VARIABLES ###

variable "redis_jobs_cluster_count" {
  description = "Number of clusters to create"
  default = 1
}

variable "redis_jobs_node_count" {
  description = "Number of cache nodes to be created. If count is 2, 1 will be a master and other wil be a replica"
  default = 2
}

variable "redis_jobs_node_type" {
  description = "Cache node type"
}

variable "redis_jobs_version" {
  description = "Redis version number"
  default = "5.0.4"
}

variable "redis_jobs_port" {
  description = "Redis port number"
  default = "6379"
}

### REDIS CACHE VARIABLES ###

variable "redis_cache_cluster_count" {
  description = "Number of clusters to create"
  default = 1
}

variable "redis_cache_node_count" {
  description = "Number of cache nodes to be created. If count is 2, 1 will be a master and other wil be a replica"
  default = 2
}

variable "redis_cache_node_type" {
  description = "Cache node type"
}

variable "redis_cache_version" {
  description = "Redis version number"
  default = "5.0.4"
}

variable "redis_cache_port" {
  description = "Redis port number"
  default = "6379"
}


# Load Balancer

variable "enable_https" {
  description = "Enable https traffic"
  default = true
}

variable "cert_crt_file_path" {
  description = "Certificate .crt file path"
  default = "../certs/server.crt"
}

variable "cert_key_file_path" {
  description = "Certificate .key file path"
  default = "../certs/server.key"
}

variable "cert_chain_file_path" {
  description = "Certificate .chain file path"
  default = "../certs/server.chain"
}

variable "enable_cloudwatch" {
  description = "Enable Cloudwatch monitoring"
  default = false
}

variable "required_data_partition" {
  description = "Data partition to be created and attached"
  default = "false"
}
