# ---------------------------
# 変数定義
# ---------------------------
locals {
  rds_name             = "${local.project_name}_${local.project_env}_rds"
  rds_engine           = "mysql"
  rds_engine_ver       = "5.7.40"
  rds_instance_class   = "db.t3.medium"
  rds_port             = 3306
  rds_user             = "admin"
  rds_password         = "jKqii59edipCR3KBhnUC"
  rds_storage_type     = "gp3"
  rds_storage_size     = 100
  rds_storage_max_size = 0 # 自動スケーリングOFF
}

# ---------------------------
# RDS（MySQL）
# ---------------------------
# サブネット定義
resource "aws_db_subnet_group" "private" {
  name       = "${local.project_name_env}-production-1a"
  subnet_ids = module.vpc.private_subnets
}

# インスタンス
resource "aws_db_instance" "master-rds" {
  name                 = local.rds_name
  identifier           = "${local.project_name_env}-master"
  engine               = local.rds_engine
  engine_version       = local.rds_engine_ver
  instance_class       = local.rds_instance_class
  port                 = local.rds_port
  username             = local.rds_user
  password             = local.rds_password
  parameter_group_name = aws_db_parameter_group.master-rds-params.name
  # サブネット指定
  db_subnet_group_name = aws_db_subnet_group.private.id
  multi_az             = false
  availability_zone    = local.az_list[0]

  # セキュリティグループ
  vpc_security_group_ids = [
    aws_security_group.allow-app.id,
  ]
  # ストレージ設定
  storage_type          = local.rds_storage_type
  allocated_storage     = local.rds_storage_size
  max_allocated_storage = local.rds_storage_max_size
  storage_encrypted     = true

  allow_major_version_upgrade  = false
  auto_minor_version_upgrade   = false
  copy_tags_to_snapshot        = true
  skip_final_snapshot          = true
  deletion_protection          = false
  performance_insights_enabled = false

  # バクアップ（ UTC )
  backup_retention_period = 7
  backup_window           = "20:00-21:00" # JST 05:00-06:00
  # メンテナンスウィンドウ（ UTC ）
  maintenance_window = "mon:19:30-mon:20:00" # JST 月曜04:30-05:00

  tags = {
    env   = local.project_env
    erole = "rds-master"
  }

  lifecycle {
    # password はセキュリティの観点から terraform で管理せず、コンソールから変更する
    ignore_changes = [
      password,
    ]
  }
}