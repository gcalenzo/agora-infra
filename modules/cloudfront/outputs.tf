output "distribution_domain_name" {
  description = "CloudFront distribution domain name (use as CNAME/alias target in Route53)"
  value       = aws_cloudfront_distribution.main.domain_name
}

output "distribution_id" {
  description = "CloudFront distribution ID"
  value       = aws_cloudfront_distribution.main.id
}

output "distribution_arn" {
  description = "CloudFront distribution ARN"
  value       = aws_cloudfront_distribution.main.arn
}

output "hosted_zone_id" {
  description = "CloudFront hosted zone ID — used as alias target in Route53 A records"
  value       = aws_cloudfront_distribution.main.hosted_zone_id
}
