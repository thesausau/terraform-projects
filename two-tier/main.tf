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

resource "aws_instance" "example" {
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