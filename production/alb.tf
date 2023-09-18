# ---------------------------
# 変数定義
# ---------------------------
locals {
  lb_type                 = "application"
  lb_tg_type              = "ip"
  lb_tg_health_check_path = "/health_check"
}

# ---------------------------
# ALB
# ---------------------------
# ALB
resource "aws_lb" "alb" {
  name               = "${local.project_name_env}-alb"
  load_balancer_type = local.lb_type
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

# Listener（ HTTP ）
resource "aws_lb_listener" "alb-listener-http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      status_code  = "200"
      message_body = "OK（test）"
    }
  }
}

# ターゲットグループ
resource "aws_lb_target_group" "alb-tg-app" {
  name                 = "${local.project_name_env}-alb-tg-app"
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = module.vpc.vpc_id
  target_type          = local.lb_tg_type
  deregistration_delay = 300
  health_check {
    path                = local.lb_tg_health_check_path
    protocol            = "HTTP"
    port                = "traffic-port"
    healthy_threshold   = 5   # 正常判定の連続成功回数
    unhealthy_threshold = 3   # 非正常判定の連続失敗回数
    timeout             = 10
    interval            = 60
    matcher             = 200
  }

  tags = {
    Name = "${local.project_name_env}-alb-tg-app"
  }
}