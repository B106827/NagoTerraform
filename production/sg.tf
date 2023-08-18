# ---------------------------
# 変数定義
# ---------------------------
locals {
  anywhere_ip = "0.0.0.0/0"
}

# ---------------------------
# Security Group
# ---------------------------
# ALB用SG
resource "aws_security_group" "alb-sg" {
  name   = "${local.project_name_env}-alb-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = [
      local.anywhere_ip
    ]
  }
  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = [
      local.anywhere_ip
    ]
  }
  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = [
      local.anywhere_ip
    ]
  }
  tags = {
    Name = "${local.project_name_env}-alb-sg"
  }
}

# VPC内接続用SG（このSGが設定されたインスタンス同士は通信可能となる)
resource "aws_security_group" "app-sg" {
  name   = "${local.project_name_env}-app-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    protocol  = "-1"
    from_port = 0
    to_port   = 0
    self      = true
  }
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = [
      local.anywhere_ip
    ]
  }
  tags = {
    Name = "${local.project_name_env}-app-sg"
  }
}
