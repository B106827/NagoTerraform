# ---------------------------
# 変数定義
# ---------------------------
locals {
  anywhere_ip = "0.0.0.0/0"
}
# ---------------------------
# Security Group
# ---------------------------
# 外部接続
resource "aws_security_group" "allow-http-from-internet" {
  name   = "${local.project_name_env}-allow-http-from-internet"
  vpc_id = module.vpc.vpc_id

  ingress {
    protocol  = "tcp"
    from_port = 80
    to_port   = 80
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
    Name = "${local.project_name_env}-allow-http-from-internet"
  }
}
resource "aws_security_group" "allow-https-from-internet" {
  name   = "${local.project_name_env}-allow-https-from-internet"
  vpc_id = module.vpc.vpc_id

  ingress {
    protocol  = "tcp"
    from_port = 443
    to_port   = 443
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
    Name = "${local.project_name_env}-allow-https-from-internet"
  }
}

# ICMP
resource "aws_security_group" "allow-all-icmp" {
  name   = "${local.project_name_env}-allow-icmp"
  vpc_id = module.vpc.vpc_id

  ingress {
    protocol    = "icmp"
    from_port   = -1
    to_port     = -1
    cidr_blocks = [
      local.vpc_cidr_block,
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
    Name = "${local.project_name_env}-allow-icmp"
  }
}

# インスタンス間接続（このSGが設定されたインスタンス同士は通信可能となる)
resource "aws_security_group" "allow-app" {
  name   = "${local.project_name_env}-allow-app"
  vpc_id = module.vpc.vpc_id

  ingress {
    protocol  = -1
    from_port = 0
    to_port   = 0
    self      = true
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
    Name = "${local.project_name_env}-allow-app"
  }
}
