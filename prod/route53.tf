# ---------------------------
# 変数定義
# ---------------------------
locals {
  # TTL
  initial_ttl = 60
  fixed_ttl   = 86400 # 86400秒=1日
}

# ---------------------------
# Route53
# ---------------------------
# ホストゾーン
# Terraform で NS レコードを作成後、レジストラ側に登録する
resource "aws_route53_zone" "main-zone" {
  name = local.project_domain
  lifecycle {
    prevent_destroy = true
  }
}
# NSレコード
resource "aws_route53_record" "main-ns-record" {
  name            = local.project_domain
  zone_id         = aws_route53_zone.main-zone.zone_id
  allow_overwrite = true
  type            = "NS"
  records         = aws_route53_zone.main-zone.name_servers
  ttl             = local.initial_ttl
}

# Aレコード for ALB
resource "aws_route53_record" "main-a-record" {
  name    = local.project_domain
  zone_id = aws_route53_zone.main-zone.zone_id
  type    = "A"
  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = true
  }
}
resource "aws_route53_record" "wildcard-a-record" {
  name    = "*.${local.project_domain}"
  zone_id = aws_route53_zone.main-zone.zone_id
  type    = "A"
  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = true
  }
}
# 検証用 CNAME レコード for ACM
resource "aws_route53_record" "dns-verify" {
  for_each = {
    for dvo in aws_acm_certificate.all-cert.domain_validation_options :
      dvo.domain_name => {
        name   = dvo.resource_record_name
        record = dvo.resource_record_value
        type   = dvo.resource_record_type
      }
  }
  zone_id         = aws_route53_zone.main-zone.zone_id
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  type            = each.value.type
  ttl             = local.initial_ttl
}
resource "aws_acm_certificate_validation" "dns-cert-validation" {
  certificate_arn = aws_acm_certificate.all-cert.arn
  validation_record_fqdns = [ for record in aws_route53_record.dns-verify : record.fqdn ]
}