# ---------------------------
# ECR
# ---------------------------
# ECR
resource "aws_ecr_repository" "nginx" {
  name = "${local.project_name_env}/nginx"
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