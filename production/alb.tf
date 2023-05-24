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
resource "aws_lb" "app-alb" {
  name               = "${local.project_name_env}-app-alb"
  load_balancer_type = local.load_balancer_type
  internal           = false
  # コネクションクローズまでの時間
  idle_timeout       = 60

  enable_deletion_protection = false

  subnets         = module.vpc.public_subnets
  security_groups = [
    aws_security_group.allow-app.id,
    aws_security_group.allow-http-from-internet.id,
    aws_security_group.allow-https-from-internet.id,
  ]

  tags = {
    Name = "${local.project_name_env}-app-alb"
    env  = local.project_env
  }
}

# TargetGroup
resource "aws_lb_target_group" "app-alb-targetgroup" {
  name        = "${local.project_name_env}-app-alb-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"

  slow_start           = 0
  # 完全にコネクションをクローズするまでの時間
  deregistration_delay = 300

  health_check {
    path                = "/healthcheck"
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
    Name = "${local.project_name_env}-app-alb-tg"
    env  = local.project_env
  }
}

# Listener
resource "aws_lb_listener" "app-alb-listener-http" {
  load_balancer_arn = aws_lb.app-alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app-alb-targetgroup.arn
    #redirect {
    #  port        = "443"
    #  protocol    = "HTTPS"
    #  status_code = "HTTP_301"
    #}
  }
}
# HTTPS化
#resource "aws_lb_listener" "app-alb-listener-https" {
#  load_balancer_arn = aws_lb.app-alb.arn
#  port              = 443
#  protocol          = "HTTPS"
#  ssl_policy        = "ELBSecurityPolicy-2016-08"
#  certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"
#  default_action {
#    type = "fixed-response"
#    fixed_response {
#      content_type = "text/plain"
#      message_body = "Not Found Host"
#      status_code  = "404"
#    }
#  }
#}

# Listener Rule
resource "aws_lb_listener_rule" "app-alb-listener-https-rule" {
  listener_arn = aws_lb_listener.app-alb-listener-http.arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app-alb-targetgroup.arn
  }

  condition {
    host_header {
      values = [
        local.project_domain
      ]
    }
  }
}