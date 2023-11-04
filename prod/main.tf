# ---------------------------
# 共通変数定義
# ---------------------------
locals {
  project_name     = "Nago"
  project_prefix   = "nago"
  project_env      = "prd"
  # 「nago-prd」
  project_name_env = "${local.project_prefix}-${local.project_env}"

  project_primary_domain = "bon-go.net"
  project_domain         = "ec.bon-go.net"

  # 東京リージョン
  region = "ap-northeast-1"
}

# ---------------------------
# AWS
# ---------------------------
# リージョン
provider "aws" {
  region = local.region
}

# AWSアカウントID(自動取得)
data "aws_caller_identity" "self" {
}
