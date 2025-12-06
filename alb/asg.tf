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

resource "aws_key_pair" "ec2" {
  key_name   = "${var.common_tags["Project"]}-ec2-asg-${random_string.string.result}"
  public_key = file(var.key_path)
}

module "asg" {
  source = "terraform-aws-modules/autoscaling/aws"

  # Autoscaling group
  name = "${var.common_tags["Project"]}-${var.asg_name}-${random_string.string.result}"

  min_size                  = var.asg_min_size
  max_size                  = var.asg_max_size
  desired_capacity          = var.asg_desired_capacity
  wait_for_capacity_timeout = 0
  health_check_type         = "EC2"
  vpc_zone_identifier       = module.vpc.private_subnets

  # Launch template
  launch_template_name   = "${var.common_tags["Project"]}-${var.alt}-${random_string.string.result}"
  update_default_version = true

  image_id          = data.aws_ami.ubuntu.id
  key_name          = aws_key_pair.ec2.key_name
  instance_type     = var.instance_type
  ebs_optimized     = true
  enable_monitoring = true


  block_device_mappings = [
    {
      # Root volume
      device_name = var.ebs_device_name
      no_device   = 0
      ebs = {
        delete_on_termination = true
        encrypted             = true
        volume_size           = var.ebs_volume_size
        volume_type           = var.ebs_volume_type
      }
    }
  ]

  capacity_reservation_specification = {
    capacity_reservation_preference = "open"
  }

  cpu_options = {
    core_count       = var.cpu_core
    threads_per_core = var.cpu_threads
  }

  instance_market_options = {
    market_type = "spot"
  }

  network_interfaces = [
    {
      delete_on_termination = true
      description           = "eth0"
      device_index          = 0
      security_groups       = [aws_security_group.allow_from_alb.id, aws_security_group.allow_ssh.id]
    }
  ]
  user_data = filebase64("${path.module}/user-data/user-data.sh")
  tag_specifications = [
    {
      resource_type = "instance"
      tags = merge(var.common_tags, {
        Name = "${var.common_tags["Project"]}-${var.ec2_name}-${random_string.string.result}"
      })
    },
    {
      resource_type = "volume"
      tags = merge(var.common_tags, {
        Name = "${var.common_tags["Project"]}-${var.volume_name}-volume-${random_string.string.result}"
      })
    },
    {
      resource_type = "spot-instances-request"
      tags = merge(var.common_tags, {
        Name = "${var.common_tags["Project"]}-${var.spot_name}-${random_string.string.result}"
      })
    }
  ]

  tags = merge(var.common_tags, {
    Name = "${var.common_tags["Project"]}-${var.asg_name}-${random_string.string.result}"
  })
}
