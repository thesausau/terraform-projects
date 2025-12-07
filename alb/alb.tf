### ALB ###
resource "aws_lb" "alb" {
  name               = "${var.common_tags["Project"]}-lb-${random_string.string.result}"
  internal           = false
  load_balancer_type = var.lb_type
  security_groups    = [aws_security_group.allow_http.id]
  subnets            = module.vpc.public_subnets

  enable_deletion_protection = false

  tags = merge(var.common_tags)
}

### ALB Target Group ###
resource "aws_lb_target_group" "alb_tg" {
  name     = "${var.common_tags["Project"]}-tg-${random_string.string.result}"
  port     = var.tg_port
  protocol = var.tg_protocol
  vpc_id   = module.vpc.vpc_id
  tags     = var.common_tags
}

### ALB Listener ###
resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = var.lb_port
  protocol          = var.lb_protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.id
  }
  tags = var.common_tags
}
