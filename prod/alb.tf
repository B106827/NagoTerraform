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
    aws_security_group.alb_sg.id
  ]

  tags = {
    Name = "${local.project_name_env}-alb"
  }
}

# Listener（ HTTP / HTTPS ）
resource "aws_lb_listener" "alb_listener_http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "redirect"
    redirect {
      protocol    = "HTTPS"
      port        = "443"
      status_code = "HTTP_301"
    }
  }
}
resource "aws_lb_listener" "alb_listener_https" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.all_cert.arn
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg_nginx.arn
  }
}

# ターゲットグループ
resource "aws_lb_target_group" "alb_tg_nginx" {
  name                 = "${local.project_name_env}-alb-tg-nginx"
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
    Name = "${local.project_name_env}-alb-tg-nginx"
  }
}