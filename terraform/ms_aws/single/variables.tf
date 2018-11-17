variable "key_name" {
  description = "Desired name of AWS key pair"
  default = "<KEY_PAIR NAME>"
}

variable "access_key" {
  description = "Aws Access key of use"
  default = "<ACCESS KEY>"
}

variable "secret_key" {
  description = "Aws  secret key of user"
  default = "<SECREET KEY>"
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default = "us-west-1"
}

# Ubuntu 16.04 (x64)
variable "aws_ami" {
   description = "AWS AMI used to create instances." 
   default = "<AMI_ID>"
}

variable "vpc_id" {
  description = "VPC ID for AWS resources."
  default = "<VPC ID>"
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
