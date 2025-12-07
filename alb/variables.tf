variable "common_tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "alb"
    Terraform   = "true"
  }
}

####VPC####

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "vpc"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnets" {
  description = "Private subnets for the VPC"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "public_subnets" {
  description = "Public subnets for the VPC"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "enable_nat_gateway" {
  description = "Enable nat gateway"
  type        = bool
  default     = true
}

variable "manage_default_route_table" {
  description = "Manage default route table"
  type        = bool
  default     = false
}

variable "single_nat_gateway" {
  description = "Manage nat gateway"
  type        = bool
  default     = true
}

####EC2 ASG####
variable "asg_name" {
  description = "Autoscaling group name"
  type        = string
  default     = "asg"
}

variable "asg_min_size" {
  description = "Minimum size of the autoscaling group"
  type        = number
  default     = 1
}

variable "asg_max_size" {
  description = "Maximum size of the autoscaling group"
  type        = number
  default     = 2
}

variable "asg_desired_capacity" {
  description = "Desired capacity for the autoscaling group"
  type        = number
  default     = 2
}


#### EC2 Launch Template ####

variable "ec2_name" {
  description = "EC2 instance name"
  type        = string
  default     = "ec2"
}

variable "volume_name" {
  description = "EC2 instance volume"
  type        = string
  default     = "volume"
}

variable "spot_name" {
  description = "EC2 instance spot"
  type        = string
  default     = "spot"
}

variable "alt" {
  description = "AWS launch template name"
  type        = string
  default     = "alt"
}

variable "key_path" {
  description = "Key path for EC2 instances"
  type        = string
  default     = "~/.ssh/id_alb.pub"

}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "market_type" {
  description = "EC2 instance market type"
  type        = string
  default     = "spot"
}

variable "market_type_price" {
  description = "EC2 instance market type price"
  type        = string
  default     = "0.01"
}

variable "ebs_device_name" {
  description = "EBS device name"
  type        = string
  default     = "/dev/sdf"
}

variable "ebs_volume_size" {
  description = "EBS volume size"
  type        = number
  default     = 10
}

variable "ebs_volume_type" {
  description = "EBS volume type"
  type        = string
  default     = "gp2"
}

variable "cpu_core" {
  description = "Core count for CPU options"
  type        = number
  default     = 1
}

variable "cpu_threads" {
  description = "Thread count for CPU options"
  type        = number
  default     = 2
}

variable "user_data" {
  description = "User data for EC2 instances"
  type        = string
  default     = "user-data.sh"
}

## Security Group ##
variable "sg_name" {
  description = "Security group name"
  type        = string
  default     = "sg"
}

## ALB ##
variable "alb_name" {
  description = "Application Load Balancer name"
  type        = string
  default     = "alb"
}

variable "lb_type" {
  description = "Load balancer type"
  type        = string
  default     = "application"
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = false
}

variable "tg_port" {
  description = "Target group port"
  type        = number
  default     = 80
}

variable "tg_protocol" {
  description = "Target group protocol"
  type        = string
  default     = "HTTP"
}

variable "lb_port" {
  description = "Load balancer port"
  type        = number
  default     = 80
}

variable "lb_protocol" {
  description = "Load balancer protocol"
  type        = string
  default     = "HTTP"
}
