###### VPC vairables ##############
variable "vpc_name" {
  description = "Name of the VPC"
  type = string
  default = "test-vpc"
}

variable "vpc_cidr" {
  description = "CIDR block size for VPC"
  type = string
  default = "10.0.0.0/16"
}

# variable "azs" {
#   description = "Availability zones"
#   type = list(string)
#   default = [ "ap-south1a" ]
# }

variable "private_subnets" {
  description = "Private subnets"
  type = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "public_subnets" {
  description = "Public subnets"
  type = list(string)
  default = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "enable_nat_gateway" {
  description = "NAT gateway should be enabled?"
  type = bool
  default = true
}

variable "enable_vpn_gateway" {
  description = "VPN gageway should be enabled?"
  type = bool
  default = true
}

###### EKS vairables ##############

variable "ng_name" {
  description = "Name of the managed node group"
  type = string
  default = "test-ng"
}
# cluster name will be test-cluster-RANDOM-SUFFIX
variable "cluster_name" {
  description = "Name of the cluster"
  type = string
  default = "test-cluster"
}

####### Common tags ###############

variable "tags" {
  description = "Common tags"
  type = map(string)
  default = {
    Environment = "dev"
    Terraform = "true"
  }
}