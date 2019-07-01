terraform {
  required_version = ">= 0.10.3" # Local Values configuration feature is allowed only in higher versions of Terraform
}

locals {
  max_subnet_length = "${max(length(var.app_subnets), length(var.worker_subnets))}"
  nat_gateway_count = "${var.single_nat_gateway ? 1 : (var.one_nat_gateway_per_az ? length(var.azs) : local.max_subnet_length)}"

  # Use `local.vpc_id` to give tell Terraform that subnets should be deleted before secondary CIDR blocks can be free
  vpc_id = "${element(concat(aws_vpc_ipv4_cidr_block_association.this.*.vpc_id, aws_vpc.this.*.id, list("")), 0)}"

  envi = "${lookup(var.tags, "Environment")}"
}

######
# VPC
######
resource "aws_vpc" "this" {
  count = "${var.create_vpc ? 1 : 0}"

  cidr_block                       = "${var.cidr}"
  instance_tenancy                 = "${var.instance_tenancy}"
  enable_dns_hostnames             = "${var.enable_dns_hostnames}"
  enable_dns_support               = "${var.enable_dns_support}"
  assign_generated_ipv6_cidr_block = "${var.assign_generated_ipv6_cidr_block}"

  tags = "${merge(map("Name", format("%s-%s-vpc", var.name, local.envi)), var.tags)}"
}

resource "aws_vpc_ipv4_cidr_block_association" "this" {
  count = "${var.create_vpc && length(var.secondary_cidr_blocks) > 0 ? length(var.secondary_cidr_blocks) : 0}"

  vpc_id = "${aws_vpc.this.id}"

  cidr_block = "${element(var.secondary_cidr_blocks, count.index)}"
}

###################
# Internet Gateway
###################
resource "aws_internet_gateway" "this" {
  count = "${var.create_vpc && length(var.public_subnets) > 0 ? 1 : 0}"

  vpc_id = "${local.vpc_id}"

  tags = "${merge(map("Name", format("%s-%s-igw", var.name, local.envi)), var.tags)}"
}

################
# Publiс/Management routes
################
resource "aws_route_table" "public" {
  count = "${var.create_vpc && length(var.public_subnets) > 0 ? 1 : 0}"

  vpc_id = "${local.vpc_id}"

  tags = "${merge(map("Name", format("%s-%s-mgt-rt", var.name, local.envi)), var.tags)}"
}

resource "aws_route" "public_internet_gateway" {
  count = "${var.create_vpc && length(var.public_subnets) > 0 ? 1 : 0}"

  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.this.id}"

  timeouts {
    create = "5m"
  }
}

################
# Load Balancer routes
################
resource "aws_route_table" "lb" {
  count = "${var.create_vpc && length(var.lb_subnets) > 0 ? 1 : 0}"

  vpc_id = "${local.vpc_id}"

  tags = "${merge(map("Name", format("%s-%s-lb-rt", var.name, local.envi)), var.tags)}"
}

resource "aws_route" "lb_internet_gateway" {
  count = "${var.create_vpc && length(var.lb_subnets) > 0 ? 1 : 0}"

  route_table_id         = "${aws_route_table.lb.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.this.id}"

  timeouts {
    create = "5m"
  }
}


#################
# app routes
# There are as many routing tables as the number of NAT gateways
#################
resource "aws_route_table" "app" {
  count = "${var.create_vpc && local.max_subnet_length > 0 ? local.nat_gateway_count : 0}"

  vpc_id = "${local.vpc_id}"

  tags = "${merge(map("Name", (var.single_nat_gateway ? "${var.name}-${local.envi}-app-rt" : format("%s-${local.envi}-app-%s-rt", var.name, element(var.azs, count.index)))), var.tags)}"
}

#################
# Worker routes
# There are as many routing tables as the number of NAT gateways
#################
resource "aws_route_table" "worker" {
  count = "${var.create_vpc && local.max_subnet_length > 0 ? local.nat_gateway_count : 0}"

  vpc_id = "${local.vpc_id}"

  tags = "${merge(map("Name", (var.single_nat_gateway ? "${var.name}-${local.envi}-worker-rt" : format("%s-${local.envi}-worker-%s-rt", var.name, element(var.azs, count.index)))), var.tags)}"
}

#################
# rds routes
#################
resource "aws_route_table" "rds" {
  count = "${var.create_vpc && var.create_rds_subnet_route_table && length(var.rds_subnets) > 0 ? 1 : 0}"

  vpc_id = "${local.vpc_id}"

  tags = "${merge(var.tags, map("Name", "${var.name}-${local.envi}-rds-rt"))}"
}

resource "aws_route" "rds_internet_gateway" {
  count = "${var.create_vpc && var.create_rds_subnet_route_table && length(var.rds_subnets) > 0 && var.create_rds_internet_gateway_route ? 1 : 0}"

  route_table_id         = "${aws_route_table.rds.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.this.id}"

  timeouts {
    create = "5m"
  }
}

#################
# Elasticache routes
#################
resource "aws_route_table" "elasticache" {
  count = "${var.create_vpc && var.create_elasticache_subnet_route_table && length(var.elasticache_subnets) > 0 ? 1 : 0}"

  vpc_id = "${local.vpc_id}"

  tags = "${merge(var.tags, map("Name", "${var.name}-${local.envi}-ec-rt"))}"
}

################
# Public/Manabement subnet
################
resource "aws_subnet" "public" {
  count = "${var.create_vpc && length(var.public_subnets) > 0 && (!var.one_nat_gateway_per_az || length(var.public_subnets) >= length(var.azs)) ? length(var.public_subnets) : 0}"

  vpc_id                  = "${local.vpc_id}"
  cidr_block              = "${element(concat(var.public_subnets, list("")), count.index)}"
  availability_zone       = "${element(var.azs, count.index)}"
  map_public_ip_on_launch = "${var.map_public_ip_on_launch}"

  tags = "${merge(map("Name", format("%s-${local.envi}-mgt-%s-subnet", var.name, element(var.azs, count.index))), var.tags)}"
}

################
# Load Balancer subnet
################
resource "aws_subnet" "lb" {
  count = "${var.create_vpc && length(var.lb_subnets) > 0 ? length(var.lb_subnets) : 0}"

  vpc_id                  = "${local.vpc_id}"
  cidr_block              = "${element(concat(var.lb_subnets, list("")), count.index)}"
  availability_zone       = "${element(var.azs, count.index)}"
  map_public_ip_on_launch = "${var.lb_map_public_ip_on_launch}"

  tags = "${merge(map("Name", format("%s-${local.envi}-lb-%s-subnet", var.name, element(var.azs, count.index))), var.tags)}"
}


#################
# app subnet
#################
resource "aws_subnet" "app" {
  count = "${var.create_vpc && length(var.app_subnets) > 0 ? length(var.app_subnets) : 0}"

  vpc_id            = "${local.vpc_id}"
  cidr_block        = "${var.app_subnets[count.index]}"
  availability_zone = "${element(var.azs, count.index)}"

  tags = "${merge(map("Name", format("%s-${local.envi}-app-%s-subnet", var.name, element(var.azs, count.index))), var.tags)}"

  depends_on = ["aws_nat_gateway.this", "aws_route.app_nat_gateway", "aws_route.worker_nat_gateway"]
}

#################
# worker subnet
#################
resource "aws_subnet" "worker" {
  count = "${var.create_vpc && length(var.worker_subnets) > 0 ? length(var.worker_subnets) : 0}"

  vpc_id            = "${local.vpc_id}"
  cidr_block        = "${var.worker_subnets[count.index]}"
  availability_zone = "${element(var.azs, count.index)}"

  tags = "${merge(map("Name", format("%s-${local.envi}-worker-%s-subnet", var.name, element(var.azs, count.index))), var.tags)}"

  depends_on = ["aws_nat_gateway.this"]
}


##################
# rds subnet
##################
resource "aws_subnet" "rds" {
  count = "${var.create_vpc && length(var.rds_subnets) > 0 ? length(var.rds_subnets) : 0}"

  vpc_id            = "${local.vpc_id}"
  cidr_block        = "${var.rds_subnets[count.index]}"
  availability_zone = "${element(var.azs, count.index)}"

  tags = "${merge(map("Name", format("%s-${local.envi}-rds-%s-subnet", var.name, element(var.azs, count.index))), var.tags)}"
}

resource "aws_db_subnet_group" "rds" {
  count = "${var.create_vpc && length(var.rds_subnets) > 0 && var.create_rds_subnet_group ? 1 : 0}"

  name        = "${lower(var.name)}-rds-subnet-group"
  description = "rds subnet group for ${var.name}"
  subnet_ids  = ["${aws_subnet.rds.*.id}"]

  tags = "${merge(map("Name", format("%s-${local.envi}-rds-subnetgroup", var.name)), var.tags)}"
}


#####################
# ElastiCache subnet
#####################
resource "aws_subnet" "elasticache" {
  count = "${var.create_vpc && length(var.elasticache_subnets) > 0 ? length(var.elasticache_subnets) : 0}"

  vpc_id            = "${local.vpc_id}"
  cidr_block        = "${var.elasticache_subnets[count.index]}"
  availability_zone = "${element(var.azs, count.index)}"

  tags = "${merge(map("Name", format("%s-${local.envi}-ec-%s-subnet", var.name, element(var.azs, count.index))), var.tags)}"
}

resource "aws_elasticache_subnet_group" "elasticache" {
  count = "${var.create_vpc && length(var.elasticache_subnets) > 0 && var.create_elasticache_subnet_group ? 1 : 0}"

  name        = "${var.name}-redis-subnet-group"
  description = "ElastiCache subnet group for ${var.name}"
  subnet_ids  = ["${aws_subnet.elasticache.*.id}"]
}


########################
# Public Network ACLs
########################
resource "aws_network_acl" "public" {
  count = "${var.create_vpc && var.public_dedicated_network_acl && length(var.public_subnets) > 0 ? 1 : 0}"

  vpc_id     = "${element(concat(aws_vpc.this.*.id, list("")), 0)}"
  subnet_ids = ["${aws_subnet.public.*.id}"]

  tags = "${merge(map("Name", format("%s-${local.envi}-mgt-nacl", var.name)), var.tags)}"
}

resource "aws_network_acl_rule" "public_inbound" {
  count = "${var.create_vpc && var.public_dedicated_network_acl && length(var.public_subnets) > 0 ? length(var.public_inbound_acl_rules) : 0}"

  network_acl_id = "${aws_network_acl.public.id}"

  egress      = false
  rule_number = "${lookup(var.public_inbound_acl_rules[count.index], "rule_number")}"
  rule_action = "${lookup(var.public_inbound_acl_rules[count.index], "rule_action")}"
  from_port   = "${lookup(var.public_inbound_acl_rules[count.index], "from_port")}"
  to_port     = "${lookup(var.public_inbound_acl_rules[count.index], "to_port")}"
  protocol    = "${lookup(var.public_inbound_acl_rules[count.index], "protocol")}"
  cidr_block  = "${lookup(var.public_inbound_acl_rules[count.index], "cidr_block")}"
}

resource "aws_network_acl_rule" "public_outbound" {
  count = "${var.create_vpc && var.public_dedicated_network_acl && length(var.public_subnets) > 0 ? length(var.public_outbound_acl_rules) : 0}"

  network_acl_id = "${aws_network_acl.public.id}"

  egress      = true
  rule_number = "${lookup(var.public_outbound_acl_rules[count.index], "rule_number")}"
  rule_action = "${lookup(var.public_outbound_acl_rules[count.index], "rule_action")}"
  from_port   = "${lookup(var.public_outbound_acl_rules[count.index], "from_port")}"
  to_port     = "${lookup(var.public_outbound_acl_rules[count.index], "to_port")}"
  protocol    = "${lookup(var.public_outbound_acl_rules[count.index], "protocol")}"
  cidr_block  = "${lookup(var.public_outbound_acl_rules[count.index], "cidr_block")}"
}


########################
# Load Balancer Network ACLs
########################
resource "aws_network_acl" "lb" {
  count = "${var.create_vpc && var.lb_dedicated_network_acl && length(var.lb_subnets) > 0 ? 1 : 0}"

  vpc_id     = "${element(concat(aws_vpc.this.*.id, list("")), 0)}"
  subnet_ids = ["${aws_subnet.lb.*.id}"]

  tags = "${merge(map("Name", format("%s-${local.envi}-mgt-nacl", var.name)), var.tags)}"
}

resource "aws_network_acl_rule" "lb_inbound" {
  count = "${var.create_vpc && var.lb_dedicated_network_acl && length(var.lb_subnets) > 0 ? length(var.lb_inbound_acl_rules) : 0}"

  network_acl_id = "${aws_network_acl.lb.id}"

  egress      = false
  rule_number = "${lookup(var.lb_inbound_acl_rules[count.index], "rule_number")}"
  rule_action = "${lookup(var.lb_inbound_acl_rules[count.index], "rule_action")}"
  from_port   = "${lookup(var.lb_inbound_acl_rules[count.index], "from_port")}"
  to_port     = "${lookup(var.lb_inbound_acl_rules[count.index], "to_port")}"
  protocol    = "${lookup(var.lb_inbound_acl_rules[count.index], "protocol")}"
  cidr_block  = "${lookup(var.lb_inbound_acl_rules[count.index], "cidr_block")}"
}

resource "aws_network_acl_rule" "lb_outbound" {
  count = "${var.create_vpc && var.lb_dedicated_network_acl && length(var.lb_subnets) > 0 ? length(var.lb_outbound_acl_rules) : 0}"

  network_acl_id = "${aws_network_acl.lb.id}"

  egress      = true
  rule_number = "${lookup(var.lb_outbound_acl_rules[count.index], "rule_number")}"
  rule_action = "${lookup(var.lb_outbound_acl_rules[count.index], "rule_action")}"
  from_port   = "${lookup(var.lb_outbound_acl_rules[count.index], "from_port")}"
  to_port     = "${lookup(var.lb_outbound_acl_rules[count.index], "to_port")}"
  protocol    = "${lookup(var.lb_outbound_acl_rules[count.index], "protocol")}"
  cidr_block  = "${lookup(var.lb_outbound_acl_rules[count.index], "cidr_block")}"
}


#######################
# app Network ACLs
#######################
resource "aws_network_acl" "app" {
  count = "${var.create_vpc && var.app_dedicated_network_acl && length(var.app_subnets) > 0 ? 1 : 0}"

  vpc_id     = "${element(concat(aws_vpc.this.*.id, list("")), 0)}"
  subnet_ids = ["${aws_subnet.app.*.id}"]

  tags = "${merge(map("Name", format("%s-${local.envi}-app-nacl", var.name)), var.tags)}"
}

resource "aws_network_acl_rule" "app_inbound" {
  count = "${var.create_vpc && var.app_dedicated_network_acl && length(var.app_subnets) > 0 ? length(var.app_inbound_acl_rules) : 0}"

  network_acl_id = "${aws_network_acl.app.id}"

  egress      = false
  rule_number = "${lookup(var.app_inbound_acl_rules[count.index], "rule_number")}"
  rule_action = "${lookup(var.app_inbound_acl_rules[count.index], "rule_action")}"
  from_port   = "${lookup(var.app_inbound_acl_rules[count.index], "from_port")}"
  to_port     = "${lookup(var.app_inbound_acl_rules[count.index], "to_port")}"
  protocol    = "${lookup(var.app_inbound_acl_rules[count.index], "protocol")}"
  cidr_block  = "${lookup(var.app_inbound_acl_rules[count.index], "cidr_block")}"
}

resource "aws_network_acl_rule" "app_outbound" {
  count = "${var.create_vpc && var.app_dedicated_network_acl && length(var.app_subnets) > 0 ? length(var.app_outbound_acl_rules) : 0}"

  network_acl_id = "${aws_network_acl.app.id}"

  egress      = true
  rule_number = "${lookup(var.app_outbound_acl_rules[count.index], "rule_number")}"
  rule_action = "${lookup(var.app_outbound_acl_rules[count.index], "rule_action")}"
  from_port   = "${lookup(var.app_outbound_acl_rules[count.index], "from_port")}"
  to_port     = "${lookup(var.app_outbound_acl_rules[count.index], "to_port")}"
  protocol    = "${lookup(var.app_outbound_acl_rules[count.index], "protocol")}"
  cidr_block  = "${lookup(var.app_outbound_acl_rules[count.index], "cidr_block")}"
}


#######################
# worker Network ACLs
#######################
resource "aws_network_acl" "worker" {
  count = "${var.create_vpc && var.worker_dedicated_network_acl && length(var.worker_subnets) > 0 ? 1 : 0}"

  vpc_id     = "${element(concat(aws_vpc.this.*.id, list("")), 0)}"
  subnet_ids = ["${aws_subnet.worker.*.id}"]

  tags = "${merge(map("Name", format("%s-${local.envi}-worker-nacl", var.name)), var.tags)}"
}

resource "aws_network_acl_rule" "worker_inbound" {
  count = "${var.create_vpc && var.worker_dedicated_network_acl && length(var.worker_subnets) > 0 ? length(var.worker_inbound_acl_rules) : 0}"

  network_acl_id = "${aws_network_acl.worker.id}"

  egress      = false
  rule_number = "${lookup(var.worker_inbound_acl_rules[count.index], "rule_number")}"
  rule_action = "${lookup(var.worker_inbound_acl_rules[count.index], "rule_action")}"
  from_port   = "${lookup(var.worker_inbound_acl_rules[count.index], "from_port")}"
  to_port     = "${lookup(var.worker_inbound_acl_rules[count.index], "to_port")}"
  protocol    = "${lookup(var.worker_inbound_acl_rules[count.index], "protocol")}"
  cidr_block  = "${lookup(var.worker_inbound_acl_rules[count.index], "cidr_block")}"
}

resource "aws_network_acl_rule" "worker_outbound" {
  count = "${var.create_vpc && var.worker_dedicated_network_acl && length(var.worker_subnets) > 0 ? length(var.worker_outbound_acl_rules) : 0}"

  network_acl_id = "${aws_network_acl.worker.id}"

  egress      = true
  rule_number = "${lookup(var.worker_outbound_acl_rules[count.index], "rule_number")}"
  rule_action = "${lookup(var.worker_outbound_acl_rules[count.index], "rule_action")}"
  from_port   = "${lookup(var.worker_outbound_acl_rules[count.index], "from_port")}"
  to_port     = "${lookup(var.worker_outbound_acl_rules[count.index], "to_port")}"
  protocol    = "${lookup(var.worker_outbound_acl_rules[count.index], "protocol")}"
  cidr_block  = "${lookup(var.worker_outbound_acl_rules[count.index], "cidr_block")}"
}



########################
# rds Network ACLs
########################
resource "aws_network_acl" "rds" {
  count = "${var.create_vpc && var.rds_dedicated_network_acl && length(var.rds_subnets) > 0 ? 1 : 0}"

  vpc_id     = "${element(concat(aws_vpc.this.*.id, list("")), 0)}"
  subnet_ids = ["${aws_subnet.rds.*.id}"]

  tags = "${merge(map("Name", format("%s-${local.envi}-rds-nacl", var.name)), var.tags)}"
}

resource "aws_network_acl_rule" "rds_inbound" {
  count = "${var.create_vpc && var.rds_dedicated_network_acl && length(var.rds_subnets) > 0 ? length(var.rds_inbound_acl_rules) : 0}"

  network_acl_id = "${aws_network_acl.rds.id}"

  egress      = false
  rule_number = "${lookup(var.rds_inbound_acl_rules[count.index], "rule_number")}"
  rule_action = "${lookup(var.rds_inbound_acl_rules[count.index], "rule_action")}"
  from_port   = "${lookup(var.rds_inbound_acl_rules[count.index], "from_port")}"
  to_port     = "${lookup(var.rds_inbound_acl_rules[count.index], "to_port")}"
  protocol    = "${lookup(var.rds_inbound_acl_rules[count.index], "protocol")}"
  cidr_block  = "${lookup(var.rds_inbound_acl_rules[count.index], "cidr_block")}"
}

resource "aws_network_acl_rule" "rds_outbound" {
  count = "${var.create_vpc && var.rds_dedicated_network_acl && length(var.rds_subnets) > 0 ? length(var.rds_outbound_acl_rules) : 0}"

  network_acl_id = "${aws_network_acl.rds.id}"

  egress      = true
  rule_number = "${lookup(var.rds_outbound_acl_rules[count.index], "rule_number")}"
  rule_action = "${lookup(var.rds_outbound_acl_rules[count.index], "rule_action")}"
  from_port   = "${lookup(var.rds_outbound_acl_rules[count.index], "from_port")}"
  to_port     = "${lookup(var.rds_outbound_acl_rules[count.index], "to_port")}"
  protocol    = "${lookup(var.rds_outbound_acl_rules[count.index], "protocol")}"
  cidr_block  = "${lookup(var.rds_outbound_acl_rules[count.index], "cidr_block")}"
}


###########################
# Elasticache Network ACLs
###########################
resource "aws_network_acl" "elasticache" {
  count = "${var.create_vpc && var.elasticache_dedicated_network_acl && length(var.elasticache_subnets) > 0 ? 1 : 0}"

  vpc_id     = "${element(concat(aws_vpc.this.*.id, list("")), 0)}"
  subnet_ids = ["${aws_subnet.elasticache.*.id}"]

  tags = "${merge(map("Name", format("%s-${local.envi}-ec-nacl", var.name)), var.tags)}"
}

resource "aws_network_acl_rule" "elasticache_inbound" {
  count = "${var.create_vpc && var.elasticache_dedicated_network_acl && length(var.elasticache_subnets) > 0 ? length(var.elasticache_inbound_acl_rules) : 0}"

  network_acl_id = "${aws_network_acl.elasticache.id}"

  egress      = false
  rule_number = "${lookup(var.elasticache_inbound_acl_rules[count.index], "rule_number")}"
  rule_action = "${lookup(var.elasticache_inbound_acl_rules[count.index], "rule_action")}"
  from_port   = "${lookup(var.elasticache_inbound_acl_rules[count.index], "from_port")}"
  to_port     = "${lookup(var.elasticache_inbound_acl_rules[count.index], "to_port")}"
  protocol    = "${lookup(var.elasticache_inbound_acl_rules[count.index], "protocol")}"
  cidr_block  = "${lookup(var.elasticache_inbound_acl_rules[count.index], "cidr_block")}"
}

resource "aws_network_acl_rule" "elasticache_outbound" {
  count = "${var.create_vpc && var.elasticache_dedicated_network_acl && length(var.elasticache_subnets) > 0 ? length(var.elasticache_outbound_acl_rules) : 0}"

  network_acl_id = "${aws_network_acl.elasticache.id}"

  egress      = true
  rule_number = "${lookup(var.elasticache_outbound_acl_rules[count.index], "rule_number")}"
  rule_action = "${lookup(var.elasticache_outbound_acl_rules[count.index], "rule_action")}"
  from_port   = "${lookup(var.elasticache_outbound_acl_rules[count.index], "from_port")}"
  to_port     = "${lookup(var.elasticache_outbound_acl_rules[count.index], "to_port")}"
  protocol    = "${lookup(var.elasticache_outbound_acl_rules[count.index], "protocol")}"
  cidr_block  = "${lookup(var.elasticache_outbound_acl_rules[count.index], "cidr_block")}"
}

##############
# NAT Gateway
##############
locals {
  nat_gateway_ips = "${split(",", (var.reuse_nat_ips ? join(",", var.external_nat_ip_ids) : join(",", aws_eip.nat.*.id)))}"
}

resource "aws_eip" "nat" {
  count = "${var.create_vpc && (var.enable_nat_gateway && !var.reuse_nat_ips) ? local.nat_gateway_count : 0}"

  vpc = true

  tags = "${merge(map("Name", format("%s-${local.envi}-%s-eip", var.name, element(var.azs, (var.single_nat_gateway ? 0 : count.index)))), var.tags)}"

  depends_on = ["aws_internet_gateway.this"]
}

resource "aws_nat_gateway" "this" {
  count = "${var.create_vpc && var.enable_nat_gateway ? local.nat_gateway_count : 0}"

  allocation_id = "${element(local.nat_gateway_ips, (var.single_nat_gateway ? 0 : count.index))}"
  subnet_id     = "${element(aws_subnet.public.*.id, (var.single_nat_gateway ? 0 : count.index))}"

  tags = "${merge(map("Name", format("%s-${local.envi}-%s-nat", var.name, element(var.azs, (var.single_nat_gateway ? 0 : count.index)))), var.tags)}"

  depends_on = ["aws_internet_gateway.this"]
}

resource "aws_route" "app_nat_gateway" {
  count = "${var.create_vpc && var.enable_nat_gateway ? local.nat_gateway_count : 0}"

  route_table_id         = "${element(aws_route_table.app.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${element(aws_nat_gateway.this.*.id, count.index)}"

  timeouts {
    create = "5m"
  }
}

resource "aws_route" "worker_nat_gateway" {
  count = "${var.create_vpc && var.enable_nat_gateway ? local.nat_gateway_count : 0}"

  route_table_id         = "${element(aws_route_table.worker.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${element(aws_nat_gateway.this.*.id, count.index)}"

  timeouts {
    create = "5m"
  }
}


######################
# VPC Endpoint for S3
######################
data "aws_vpc_endpoint_service" "s3" {
  count = "${var.create_vpc && var.enable_s3_endpoint ? 1 : 0}"

  service = "s3"
}

resource "aws_vpc_endpoint" "s3" {
  count = "${var.create_vpc && var.enable_s3_endpoint ? 1 : 0}"

  vpc_id       = "${local.vpc_id}"
  service_name = "${data.aws_vpc_endpoint_service.s3.service_name}"
}

resource "aws_vpc_endpoint_route_table_association" "app_s3" {
  count = "${var.create_vpc && var.enable_s3_endpoint ? local.nat_gateway_count : 0}"

  vpc_endpoint_id = "${aws_vpc_endpoint.s3.id}"
  route_table_id  = "${element(aws_route_table.app.*.id, count.index)}"
}

resource "aws_vpc_endpoint_route_table_association" "worker_s3" {
  count = "${var.create_vpc && var.enable_s3_endpoint ? local.nat_gateway_count : 0}"

  vpc_endpoint_id = "${aws_vpc_endpoint.s3.id}"
  route_table_id  = "${element(aws_route_table.worker.*.id, count.index)}"
}


resource "aws_vpc_endpoint_route_table_association" "public_s3" {
  count = "${var.create_vpc && var.enable_s3_endpoint && length(var.public_subnets) > 0 ? 1 : 0}"

  vpc_endpoint_id = "${aws_vpc_endpoint.s3.id}"
  route_table_id  = "${aws_route_table.public.id}"
}


##########################
# Route table association
##########################
resource "aws_route_table_association" "app" {
  count = "${var.create_vpc && length(var.app_subnets) > 0 ? length(var.app_subnets) : 0}"

  subnet_id      = "${element(aws_subnet.app.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.app.*.id, (var.single_nat_gateway ? 0 : count.index))}"
}

resource "aws_route_table_association" "worker" {
  count = "${var.create_vpc && length(var.worker_subnets) > 0 ? length(var.worker_subnets) : 0}"

  subnet_id      = "${element(aws_subnet.worker.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.worker.*.id, (var.single_nat_gateway ? 0 : count.index))}"
}

resource "aws_route_table_association" "rds" {
  count = "${var.create_vpc && length(var.rds_subnets) > 0 ? length(var.rds_subnets) : 0}"

  subnet_id      = "${element(aws_subnet.rds.*.id, count.index)}"
  route_table_id = "${element(coalescelist(aws_route_table.rds.*.id, aws_route_table.app.*.id), (var.single_nat_gateway || var.create_rds_subnet_route_table ? 0 : count.index))}"
}


resource "aws_route_table_association" "elasticache" {
  count = "${var.create_vpc && length(var.elasticache_subnets) > 0 ? length(var.elasticache_subnets) : 0}"

  subnet_id      = "${element(aws_subnet.elasticache.*.id, count.index)}"
  route_table_id = "${element(coalescelist(aws_route_table.elasticache.*.id, aws_route_table.app.*.id), (var.single_nat_gateway || var.create_elasticache_subnet_route_table ? 0 : count.index))}"
}


resource "aws_route_table_association" "public" {
  count = "${var.create_vpc && length(var.public_subnets) > 0 ? length(var.public_subnets) : 0}"

  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "lb" {
  count = "${var.create_vpc && length(var.lb_subnets) > 0 ? length(var.lb_subnets) : 0}"

  subnet_id      = "${element(aws_subnet.lb.*.id, count.index)}"
  route_table_id = "${aws_route_table.lb.id}"
}
