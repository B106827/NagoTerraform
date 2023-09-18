# ---------------------------
# ECR
# ---------------------------
# ECR
resource "aws_ecr_repository" "app" {
  name = "${local.project_name_env}/app"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}
resource "aws_ecr_repository" "api" {
  name = "${local.project_name_env}/api"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}