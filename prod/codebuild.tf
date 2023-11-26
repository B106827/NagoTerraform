# ---------------------------
# 変数定義
# ---------------------------
locals {
  # リポジトリ
  repos_url                  = "https://github.com/B106827/Nago.git"
  docker_hub_my_access_token = "dckr_pat_erlBrGrytb0BL1IUrw43xBGXAuQ"
}

# ---------------------------
# CodeBuild
# ---------------------------
resource "aws_codebuild_project" "main_project" {
  name          = "${local.project_name_env}-main-project"
  # 紐づけるIAMロール
  service_role  = aws_iam_role.codebuild_iam_role.arn
  build_timeout = "60"
  # 入力ソース
  source {
    type            = "GITHUB"
    location        = local.repos_url
    git_clone_depth = 1
    buildspec       = "etc/buildspec.yml"
  }
  # ビルド成果物の設定
  artifacts {
    type = "NO_ARTIFACTS"
  }
  # ビルドマシンに関する設定
  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:4.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    # ビルド時に利用する環境変数
    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = data.aws_caller_identity.self.account_id
    }
    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = local.region
    }
    environment_variable {
      name  = "DOCKER_HUB_MY_ACCESS_TOKEN"
      value = local.docker_hub_my_access_token
    }
  }
}
# GitHub からの Webhook（下記は CodeBuild から GitHub に連携してからでないと権限エラーとなる）
resource "aws_codebuild_webhook" "main_webook" {
  project_name = aws_codebuild_project.main_project.name
  filter_group {
    filter {
      type = "EVENT"
      pattern = "PUSH"
    }
    filter {
      type = "HEAD_REF"
      pattern = "refs/heads/main"
    }
  }
}
