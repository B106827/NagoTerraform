# ---------------------------
# ロール
# ---------------------------
# CodeBuild汎用ロール
data "aws_iam_policy_document" "codebuild_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}
resource "aws_iam_role" "codebuild" {
  name               = "${local.project_name_env}-codebuild-generic"
  assume_role_policy = data.aws_iam_policy_ducument.codebuid_assume_role.json
  description        = "CodeBuild Role for Nago Project"
}
