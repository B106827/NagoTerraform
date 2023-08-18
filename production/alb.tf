# ---------------------------
# 変数定義
# ---------------------------
locals {
  load_balancer_type = "application"
}

# ---------------------------
# ALB
# ---------------------------
# ALB
resource "aws_lb" "alb" {
  name               = "${local.project_name_env}-alb"
  load_balancer_type = local.load_balancer_type
  # コネクションクローズまでの時間
  idle_timeout       = 60

  internal                   = false
  enable_deletion_protection = false

  subnets         = module.vpc.public_subnets
  security_groups = [
    aws_security_group.alb-sg.id
  ]

  tags = {
    Name = "${local.project_name_env}-alb"
  }
}

# TargetGroup
resource "aws_lb_target_group" "alb-tg" {
  name        = "${local.project_name_env}-alb-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"

  slow_start           = 0
  # 完全にコネクションをクローズするまでの時間
  deregistration_delay = 300

  health_check {
    path                = "/health_check"
    port                = 80
    protocol            = "HTTP"
    healthy_threshold   = 5
    unhealthy_threshold = 3
    timeout             = 10
    interval            = 30
    matcher             = 200
  }

  load_balancing_algorithm_type = "round_robin"

  tags = {
    Name = "${local.project_name_env}-alb-tg"
  }
}

# Listener（ HTTP ）
resource "aws_lb_listener" "alb-listener-http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# Listener（ HTTPS ）
resource "aws_lb_listener" "alb-listener-https" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = aws_acm_certificate.app-cert.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb-tg.arn
  }
}