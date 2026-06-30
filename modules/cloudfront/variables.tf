variable "name_prefix" {
  description = "Prefix applied to all resource names"
  type        = string
}

variable "domain_name" {
  description = "Primary domain name for the CloudFront distribution"
  type        = string
}

variable "acm_certificate_arn" {
  description = "ARN of the ACM certificate in us-east-1"
  type        = string
}

variable "frontend_bucket_name" {
  description = "Name of the S3 bucket hosting SPA assets (used as bucket ID in the bucket policy)"
  type        = string
}

variable "frontend_bucket_arn" {
  description = "ARN of the S3 bucket hosting SPA assets (used in the OAC bucket policy)"
  type        = string
}

variable "frontend_bucket_regional_domain_name" {
  description = "Regional domain name of the S3 bucket (used as CloudFront S3 origin domain)"
  type        = string
}

variable "alb_dns_name" {
  description = "DNS name of the internal ALB (API origin)"
  type        = string
}

variable "alb_arn" {
  description = "ARN of the internal ALB (required for VPC Origin association)"
  type        = string
}

variable "tags" {
  description = "Tags applied to all resources"
  type        = map(string)
  default     = {}
}
