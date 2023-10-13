# ---------------------------
# 変数定義
# ---------------------------
locals {
  db_engine           = "mysql"
  db_engine_version   = "8.0.32"
  db_instance_class   = "db.t3.micro"
  db_port             = 3306
  db_master_username = "root"
  db_master_password = "bongo2204"

  db_multi_az = false

  db_storage_type = "gp2"
  db_storage_size = 10
}

# ---------------------------
# RDS
# ---------------------------
# RDS 用サブネットグループ
resource "aws_db_subnet_group" "private" {
  name       = "${local.project_name_env}-private-subnet-group"
  subnet_ids = module.vpc.private_subnets
}

# RDS インスタンス
resource "aws_db_instance" "rds" {
  name                 = "${local.project_prefix}_${local.project_env}_rds"
  identifier           = "${local.project_name_env}-rds"
  db_subnet_group_name = aws_db_subnet_group.private.id
  engine               = local.db_engine
  engine_version       = local.db_engine_version
  instance_class       = local.db_instance_class
  port                 = local.db_port
  username             = local.db_master_username
  password             = local.db_master_password
  # Multi AZ
  multi_az = local.db_multi_az
  # ストレージ設定
  storage_type      = local.db_storage_type
  allocated_storage = local.db_storage_size
  # セキュリティグループ
  vpc_security_group_ids = [
     aws_security_group.app_sg.id,
  ]
  # CloudWatch に出力するログ
  enabled_cloudwatch_logs_exports = [
    "error",
    "general",
    "slowquery"
  ]
  tags = {
    Name = "${local.project_name_env}-rds"
  }
}