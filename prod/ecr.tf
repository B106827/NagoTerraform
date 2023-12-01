# ---------------------------
# 変数定義
# ---------------------------
locals {
  repository_app_name = "${local.project_name_env}/nginx"
  repository_api_name = "${local.project_name_env}/api"
}

# ---------------------------
# ECR
# ---------------------------
# ECR
resource "aws_ecr_repository" "nginx" {
  name = local.repository_app_name
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}
resource "aws_ecr_repository" "api" {
  name = local.repository_api_name
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}