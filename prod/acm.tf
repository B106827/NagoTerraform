# ---------------------------
# ACM
# ---------------------------
# ACM
resource "aws_acm_certificate" "all_cert" {
  domain_name               = local.project_primary_domain
  subject_alternative_names = ["*.${local.project_primary_domain}"]
  validation_method         = "DNS"
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Name = "${local.project_name_env}-acm"
  }
}
