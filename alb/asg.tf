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

### SSH key pair ###
resource "aws_key_pair" "ec2" {
  key_name   = "${var.common_tags["Project"]}-ec2-asg-${random_string.string.result}"
  public_key = file(var.key_path)
}

### aws launch template ###

resource "aws_launch_template" "lt" {
  name                    = "${var.common_tags["Project"]}-template-${random_string.string.result}"
  image_id                = data.aws_ami.ubuntu.id
  instance_type           = var.instance_type
  disable_api_termination = false
  key_name                = aws_key_pair.ec2.key_name
  ebs_optimized           = true

  instance_market_options {
    market_type = var.market_type
    spot_options {
      max_price = var.market_type_price
    }
  }
  block_device_mappings {
    device_name = var.ebs_device_name
    ebs {
      delete_on_termination = true
      encrypted             = true
      volume_size           = var.ebs_volume_size
      volume_type           = var.ebs_volume_type
    }
  }
  cpu_options {
    core_count       = var.cpu_core
    threads_per_core = var.cpu_threads
  }
  monitoring {
    enabled = true
  }
  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.allow_from_alb.id, aws_security_group.allow_ssh.id]
  }
  tag_specifications {
    resource_type = "instance"
    tags = merge(var.common_tags, {
      Name = "${var.common_tags["Project"]}-template-${random_string.string.result}"
    })
  }
  user_data = filebase64("${path.module}/user-data/user-data.sh")
}

### Autoscaling group ###
resource "aws_autoscaling_group" "asg" {
  name = "${var.common_tags["Project"]}-${var.asg_name}-${random_string.string.result}"

  min_size                  = var.asg_min_size
  max_size                  = var.asg_max_size
  desired_capacity          = var.asg_desired_capacity
  wait_for_capacity_timeout = 0
  health_check_type         = "EC2"
  force_delete              = true
  vpc_zone_identifier       = module.vpc.private_subnets
  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }
  target_group_arns = [aws_lb_target_group.alb_tg.arn]
  tag {
    key                 = "Name"
    value               = "${var.common_tags["Project"]}-${var.asg_name}-${random_string.string.result}"
    propagate_at_launch = true
  }
}
