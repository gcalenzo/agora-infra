# Custom module — VPC Origin on private ALB not supported by community modules.
# ACM certificate and Route53 record are managed in dns.tf.

module "cloudfront" {
  source = "./modules/cloudfront"

  name_prefix                          = local.name_prefix
  domain_name                          = local.domain_name
  acm_certificate_arn                  = data.aws_acm_certificate.cloudfront.arn
  frontend_bucket_name                 = var.frontend_bucket_name
  frontend_bucket_arn                  = aws_s3_bucket.frontend.arn
  frontend_bucket_regional_domain_name = aws_s3_bucket.frontend.bucket_regional_domain_name
  alb_dns_name                         = module.alb.dns_name
  alb_arn                              = module.alb.arn
  tags                                 = local.common_tags

  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }
}
