# ---------------------------
# 変数定義
# ---------------------------
locals {
  s3_public_bucket = "${local.project_name_env}-s3-public"
}

# ---------------------------
# S3
# ---------------------------
# バケット
resource "aws_s3_bucket" "public" {
  bucket        = local.s3_public_bucket
  # 本番環境では false にすること
  force_destroy = true
  policy        = data.aws_iam_policy_document.public-bucket-policy.json
}

# ACL
resource "aws_s3_bucket_acl" "public-bucket-acl" {
  bucket = aws_s3_bucket.public.id
  acl    = "private"
}

# ライフサイクルルール
resource "aws_s3_bucket_lifecycle_configuration" "public-bucket-lifecycle" {
  bucket = aws_s3_bucket.public.id
  rule {
    id     = "lifecycle-rule"
    status = "Disabled"
  }
}

# CORS ルール
#resource "aws_s3_bucket_cors_configuration" "public-bucket-cors" {
#  bucket = aws_s3_bucket.public.id
#  cors_rule {
#    allowed_headers = ["*"]
#    allowed_methods = ["GET", "PUT", "POST", "HEAD"]
#    allowed_origins = ["https://${local.project_domain}"]
#    max_age_seconds = 3000
# }
#}

# パブリックアクセス設定（パブリックアクセス無効）
resource "aws_s3_bucket_public_access_block" "public-bucket-bublicaccess" {
  bucket                  = aws_s3_bucket.public.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# デフォルト暗号化設定
resource "aws_s3_bucket_server_side_encryption_configuration" "public-bucket-sse" {
  bucket = aws_s3_bucket.public.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256" # SSE-S3
    }
  }
}

# IAMポリシー
data "aws_iam_policy_document" "public-bucket-policy" {
  # CloudFrontからのアクセスはOAIで許可
  statement {
    sid     = "Access-from-CloudFront"
    effect  = "Allow"
    actions = ["s3:GetObject*"]
    resources = ["arn:aws:s3:::${local.s3_public_bucket}/*"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}