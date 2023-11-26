# ---------------------------
# 変数定義
# ---------------------------
locals {
  iam_role_for_codebuild   = "${local.project_name_env}-iam-role-codebuild"
  iam_policy_for_codebuild = "${local.project_name_env}-iam-policy-codebuild"
}

# ---------------------------
# IAM for CodeBuild
# ---------------------------
# IAM Role
resource "aws_iam_role" "codebuild_iam_role" {
  name               = local.iam_role_for_codebuild
  assume_role_policy = data.aws_iam_policy_document.codebuild_role_policy.json
}
# IAM Policy Document
data "aws_iam_policy_document" "codebuild_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}
# IAM Policy
resource "aws_iam_policy" "codebuild_policy" {
  name   = local.iam_policy_for_codebuild
  policy = file("./policy/codebuild_policy.json")
}
# Policy Attachment（ロールとポリシーの紐付け）
resource "aws_iam_role_policy_attachment" "codebuid_policy_attachement" {
  role       = aws_iam_role.codebuild_iam_role.name
  policy_arn = aws_iam_policy.codebuild_policy.arn
}
