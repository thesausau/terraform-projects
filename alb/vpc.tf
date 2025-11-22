data "aws_availability_zones" "available" {}
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  cidr = var.vpc_cidr
  azs             = slice(data.aws_availability_zones.available.names, 0, 2)
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets
  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway
  manage_default_route_table = var.manage_default_route_table

  tags = merge(
    var.common_tags,
    {
      Name = "${var.common_tags["Project"]}-${var.vpc_name}-${random_string.string.result}"
    }
  )
}