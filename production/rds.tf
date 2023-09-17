# ---------------------------
# 変数定義
# ---------------------------
locals {
}

# ---------------------------
# RDS
# ---------------------------
# RDS 用サブネットグループ
resource "aws_db_subnet_group" "private" {
  name       = "${local.project_name_env}-private-subnet-group"
  subnet_ids = module.vpc.private_subnets
}