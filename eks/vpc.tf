module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc_name
  cidr = var.vpc_cidr
  
  #to modify as per az selected
  azs             = slice(data.aws_availability_zones.available.names, 0, 3)
  private_subnets = var.public_subnets
  public_subnets  = var.private_subnets

  enable_nat_gateway = var.enable_nat_gateway
  enable_vpn_gateway = var.enable_vpn_gateway

  tags = var.tags
}
