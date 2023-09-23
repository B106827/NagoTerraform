# ---------------------------
# ロール
# ---------------------------
# ECS用ロール
data "aws_iam_policy_document" "ecs_task_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}
resource "aws_iam_role" "ecs_task_role" {
  name               = "${local.project_name_env}-ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
}
resource "aws_iam_role" "ecs_task_execute_role" {
  name               = "${local.project_name_env}-ecs-task-execute-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
}

# CodeBuild用ロール
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
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role.json
  description        = "CodeBuild Role for Nago Project"
}
