# ---------------------------
# Route53
# ---------------------------
# Route53（ホストゾーン）
# Terraform で NS レコードを作成後、レジストラ側に登録する
resource "aws_route53_zone" "app" {
  name = local.project_domain
  lifecycle {
    prevent_destroy = true
  }
}
# Route53（レコード）
resource "aws_route53_record" "app-dns" {
  name    = local.project_domain
  zone_id = aws_route53_zone.app.zone_id
  type    = "A"
  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = false
  }
}
resource "aws_route53_record" "wildcard-app-dns" {
  name    = "*.${local.project_domain}"
  zone_id = aws_route53_zone.app.zone_id
  type    = "A"
  alias {
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = false
  }
}
# Route53（ DNS 検証レコード）
resource "aws_route53_record" "app-dns-verify" {
  for_each = {
    for dvo in aws_acm_certificate.app-cert.domain_validation_options : dvo.domain_name => {
      name = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id         = aws_route53_zone.app.id
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  type            = each.value.type
  ttl             = 60
}
resource "aws_acm_certificate_validation" "app-cert" {
  certificate_arn = aws_acm_certificate.app-cert.arn
  validation_record_fqdns = [for record in aws_route53_record.app-dns-verify : record.fqdn]
}