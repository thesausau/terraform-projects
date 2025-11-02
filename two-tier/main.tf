locals {
  project = "test"
}

variable "vpc" {
  description = "VPC cidr block"
}

variable "public_subs" {
  description = "Public subnets to create"
  type = map(object({
    cidr_block = string
    availability_zone = string
  }))
}

variable "private_subs" {
  description = "Private subnets to create"
  type = map(object({
    cidr_block = string
    availability_zone = string
  }))
}

resource "aws_vpc" "vpc" {
  cidr_block = var.vpc
  tags = {Name = "${local.project}-vpc"}
}

resource "aws_subnet" "public_sub" {
  for_each = var.public_subs
  vpc_id     = aws_vpc.vpc.id
  cidr_block = each.value.cidr_block
  availability_zone = each.value.availability_zone

  tags = {
    Name = "${local.project}-${each.key}"
  }
}

resource "aws_subnet" "private_sub" {
  for_each = var.private_subs
  vpc_id     = aws_vpc.vpc.id
  cidr_block = each.value.cidr_block
  availability_zone = each.value.availability_zone

  tags = {
    Name = "${local.project}-${each.key}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${local.project}-igw"
  }
}

resource "aws_route_table" "rt_pub" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${local.project}-rt_pub"
  }
}


resource "aws_route_table_association" "rta" {
  for_each = var.public_subs
  subnet_id      =  aws_subnet.public_sub[each.key].id
  route_table_id = aws_route_table.rt_pub.id
}

variable "sgs" {
  description = "Security group rules"
  type = map(object({
    inbound_rules = list(map(object({
      cidr_ipv4 = string
      port = number
      ip_protocol = string
    })))
    outbound_rules = list(map(object({
      cidr_ipv4 = string
      ip_protocol = string
    })))
  }))
}

resource "aws_security_group" "sg" {
  for_each = var.sgs
  name        = each.key
  description = "Allow SSH inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "${local.project}-${each.key}"
  }
}

locals {
  inbound_rules = flatten([
    for sg_name, sg in var.sgs : [
      for rule_obj in sg.inbound_rules : [
        for rule_name, rule in rule_obj : {
          sg_name      = sg_name
          rule_name    = rule_name
          rule         = rule
        }
      ]
    ]
  ])
}

resource "aws_vpc_security_group_ingress_rule" "this" {
  for_each = {
    for rule in local.inbound_rules :
      "${rule.sg_name}-${rule.rule_name}" => rule
  }

  security_group_id = aws_security_group.sg[each.value.sg_name].id
  cidr_ipv4         = each.value.rule.cidr_ipv4
  from_port         = each.value.rule.port
  ip_protocol       = each.value.rule.ip_protocol
  to_port           = each.value.rule.port
}

# resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
#   for_each = var.sgs
#   security_group_id = aws_security_group.sg[each.key].id
#   cidr_ipv4         = each.value.outbound_rules[*].cidr_ipv4
#   ip_protocol       = each.value.outbound_rules[*].ip_protocol # semantically equivalent to all ports
# }

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "ec2" {
  for_each = var.public_subs
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  associate_public_ip_address = true
  availability_zone = each.value.availability_zone
  subnet_id = aws_subnet.public_sub[each.key].id
  tags = {
    Name = "${local.project}-ec2"
  }
}

