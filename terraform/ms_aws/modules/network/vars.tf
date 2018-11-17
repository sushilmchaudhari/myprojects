variable "key_name" {
  description = "Desired name of AWS key pair"
  default = "nextgen_key_pair"
}

# Ubuntu 16.04 (x64)
variable "aws_ami" {
   description = "AWS AMI used to create instances." 
   default = "ami-1c71497c"
}

variable "vpc_id" {
  description = "VPC ID for AWS resources."
  default = "vpc-f4e5ec90"
}

variable "az_id" {
  description = "AZ used to create EC2 instances."
}

variable "subnet_id" {
  description = "Subnet for EC2 instances."
}

variable "sg_name" {
  description = "Security Group for EC2 instances."
}

variable "instance_type" {
  description = "Type of instance eg: t1.micro , t2.micro etc."
}

variable "instance_count" {
  description = "Number of instances to create."
}

variable "is_eip" {
  description = "Create an EIP for the instance if an instance is in Public Subnet."
}

variable "app_name" {}

variable "env_name" {}
