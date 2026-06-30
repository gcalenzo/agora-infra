output "cloudfront_distribution_domain" {
  description = "CloudFront distribution domain name (use as CNAME target in Route53)"
  value       = module.cloudfront.distribution_domain_name
}

output "alb_dns_name" {
  description = "Internal ALB DNS name — not publicly accessible, reachable only via CloudFront VPC Origin"
  value       = module.alb.dns_name
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = module.ecs_cluster.cluster_name
}

output "rds_endpoint" {
  description = "RDS primary instance endpoint (write)"
  value       = module.rds.db_instance_endpoint
  sensitive   = true
}

output "rds_read_replica_endpoint" {
  description = "RDS read replica endpoint (read-heavy queries)"
  value       = aws_db_instance.read_replica.endpoint
  sensitive   = true
}

output "sqs_queue_url" {
  description = "SQS queue URL for async task messages"
  value       = aws_sqs_queue.tasks.url
}

output "dlq_url" {
  description = "Dead Letter Queue URL — messages here have exhausted all retry attempts"
  value       = aws_sqs_queue.dlq.url
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}
