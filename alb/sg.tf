# Allow http traffic
resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow inbound traffic and all outbound traffic"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "${var.common_tags["Project"]}-${var.sg_name}-${random_string.string.result}"
  }
}

# For ALB
resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4_alb" {
  security_group_id = aws_security_group.allow_http.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4_alb" {
  security_group_id = aws_security_group.allow_http.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

##################
##################

# Allow alb traffic
resource "aws_security_group" "allow_from_alb" {
  name        = "allow_from_alb"
  description = "Allow http inboundtraffic from alb"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "${var.common_tags["Project"]}-${var.sg_name}-${random_string.string.result}"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4_ec2" {
  security_group_id = aws_security_group.allow_from_alb.id
  # cidr_ipv4         = "0.0.0.0/0"
  referenced_security_group_id = aws_security_group.allow_http.id
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4_ec2_1" {
  security_group_id = aws_security_group.allow_from_alb.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

##################
##################

# Allow ssh traffic
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow ssh inbound traffic"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "${var.common_tags["Project"]}-${var.sg_name}-${random_string.string.result}"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4_ec2" {
  security_group_id = aws_security_group.allow_ssh.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4_ec2_2" {
  security_group_id = aws_security_group.allow_ssh.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}