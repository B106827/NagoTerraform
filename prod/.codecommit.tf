# ---------------------------
# CodeCommit
# ---------------------------
resource "aws_codecommit_repository" "source" {
  repository_name = local.project_name_env
  description     = "Application Source"
}
