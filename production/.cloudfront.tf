# ---------------------------
# 変数定義
# ---------------------------
locals {
  price_class = "PriceClass_200"
  default_ttl_sec = 86400 # 1日
  max_ttl_sec     = 31536000 # 1年
  min_ttl_sec     = 3600 # 1時間

  error_code          = 404
  error_response_code = 404
  error_page_path     = "/error_404.html"
}

# ---------------------------
# CloudFront
# ---------------------------
resource "aws_cloudfront_distribution" "cf-distr"{
  enabled         = true
  is_ipv6_enabled = false

  # destribution用のCNAME
  aliases = ["cdn.example.com"]

  price_class = local.price_class

  # S3アクセス用
  origin {
    domain_name = aws_s3_bucket.public.bucket_regional_domain_name
    origin_id   = "${local.project_name_env}-public"
    s3_origin_config {
      # S3で許可するOAI
      origin_access_identity = aws_cloudfront_origin_access_identity.cf-oai.cloudfront_access_identity_path
    }
  }

  # 制限
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # SSL証明書の設定
  viewer_certificate {
    cloudfront_default_certificate = true
  }

  # キャッシュ設定
  default_cache_behavior {
    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD", "OPTIONS"]
    
    # デフォルトのオリジン
    target_origin_id = "${local.project_name_env}-public"

    # 転送設定（キャッシュ効率落ちるため最低限にする）
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
      headers = ["User-agent", "Origin"]
    }
    viewer_protocol_policy = "redirect-to-https"
    # キャッシュ時間
    default_ttl = local.default_ttl_sec
    min_ttl     = local.min_ttl_sec
    max_ttl     = local.max_ttl_sec
  }

  # エラーレスポンス設定
  custom_error_response {
    error_caching_min_ttl = 300
    error_code            = local.error_code
    response_code         = local.error_response_code
    response_page_path    = local.error_page_path
  }

  # アクセスログ設定
  # loggiing_config {}

  tags = {
    Name = "${local.project_name_env}-production-cf"
    env  = local.project_env
  }
}

# OAI
resource "aws_cloudfront_origin_access_identity" "cf-oai" {
  comment = "${local.project_name_env}-production-cf-oai"
}
