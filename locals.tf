locals {
  name_prefix = "${var.project_name}-${var.environment}"

  # prod → "agora.example.com"  |  dev/staging → "dev.agora.example.com"
  domain_name = var.environment == "prod" ? var.hosted_zone_name : "${var.environment}.${var.hosted_zone_name}"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}
