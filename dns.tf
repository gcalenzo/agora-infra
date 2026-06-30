# Route53 hosted zone lookup — var.hosted_zone_name is the name filter for the data source.

data "aws_route53_zone" "main" {
  name         = var.hosted_zone_name
  private_zone = false
}

# ACM certificate must exist in us-east-1 (CloudFront requirement).
# The domain is derived from local.domain_name (see locals.tf).
data "aws_acm_certificate" "cloudfront" {
  provider    = aws.us_east_1
  domain      = local.domain_name
  statuses    = ["ISSUED"]
  most_recent = true
}

resource "aws_route53_record" "cloudfront_alias" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = local.domain_name
  type    = "A"

  alias {
    name                   = module.cloudfront.distribution_domain_name
    zone_id                = module.cloudfront.hosted_zone_id
    evaluate_target_health = false
  }
}
