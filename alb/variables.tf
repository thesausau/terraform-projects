variable "common_tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {
    Environment = "dev"
    Project     = "alb"
    Terraform = "true"
  }
}

####VPC####

variable "vpc_name" {
  description = "Name of the VPC"
  type = string
  default = "vpc"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnets" {
  description = "Private subnets for the VPC"
  type = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "public_subnets" {
  description = "Public subnets for the VPC"
  type = list(string)
  default = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "enable_nat_gateway" {
  description = "Enable nat gateway"
  type = bool
  default = true
}

variable "manage_default_route_table" {
  description = "Manage default route table"
  type = bool
  default = false
}

variable "single_nat_gateway" {
  description = "Manage nat gateway"
  type = bool
  default = true
}