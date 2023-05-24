# ---------------------------
# 変数定義
# ---------------------------
locals {
  project_name     = "fungry"
  project_env      = "production"
  project_name_env = "${local.project_name}-${local.project_env}"

  project_domain   = "example.com"

  # 東京リージョン
  region = "ap-northeast-1"

  # 外部からアクセスする場合のDNS名
  cf-dns = "cdn.${local.project_domain}"
}

# ---------------------------
# AWS
# ---------------------------
provider "aws" {
  region = local.region
}
