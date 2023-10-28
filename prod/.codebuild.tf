# ---------------------------
# 変数定義
# ---------------------------
locals {
  project_source_branch = "main"
  image_tag             = "latest"
  build_env_list = {
    TEST_ENV1 = "hoge"
    TEST_ENV2 = "fuga"
  }
}

# ---------------------------
# CodeBuild
# ---------------------------
resource "aws_codebuild_project" "api" {
  name          = "${local.project_name_env}-api"
  description   = "api(Go)コンテナビルド"
  # 紐づけるIAMロール
  service_role  = aws_iam_role.codebuild.arn
  build_timeout = "60"

  # ビルド成果物の設定
  artifacts {
    type = "NO_ARTIFACTS"
  }

  cache {
    type = "LOCAL"
    modes = [
      "LOCAL_SOURCE_CACHE"
      "LOCAL_CUSTOM_CACHE"
    ]
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:4.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    # ビルド時に利用する環境変数
    environment_variable {
      name = "AWS_ACCOUNT_ID"
      value = data.aws_caller_identity.self.account_id
    }
    environment_variable {
      name = "AWS_DEFAULT_REGION"
      value = data.aws_caller_identity.self.account_id
    }
    environment_variable {
      name = "DOCKERHUB_REPO"
      value = "${local.project_name_env}/dockerhub"
    }
    environment_variable {
      name = "CONTAINER_NAME"
      value = "${local.project_name_env}-api-container"
    }
    environment_variable {
      name = "IMAGE_REPO_NAME"
      value = "${local.project_name_env}/api"
    }
    environment_variable {
      name = "IMAGE_TAG"
      value = local.image_tag
    }
    dynamic environment_variable {
      for_each = local.build_env_list
      content {
        name  = environment_variable.key
        value = environment_variable.value
      }
    }
  }

  source_version = "refs/heads/${local.project_source_branch}"
  source {
    type            = "CODECOMMIT"
    location        = "https://git-codecommit.ap-northeast-1.amazonaws.com/v1/repos/${local.project_name_env}"
    git_clone_depth = 1
    buildspec       = "backend/buildspec.yml"
  }
}
