variable "name_prefix" {
  description = "Prefix applied to all resource names"
  type        = string
}

variable "ecs_cluster_name" {
  description = "ECS cluster name for CloudWatch metrics"
  type        = string
}

variable "ecs_service_name" {
  description = "ECS service name for CloudWatch metrics"
  type        = string
}

variable "alb_arn_suffix" {
  description = "ALB ARN suffix for CloudWatch metrics (e.g. app/my-alb/1234567890abcdef)"
  type        = string
}

variable "rds_identifier" {
  description = "RDS instance identifier for CloudWatch metrics"
  type        = string
}

variable "dlq_name" {
  description = "DLQ queue name for CloudWatch metrics"
  type        = string
}

variable "aws_region" {
  description = "AWS region — used to pin CloudWatch dashboard widgets to the correct region"
  type        = string
}

variable "log_retention_days" {
  description = "Retention period for CloudWatch log groups in days"
  type        = number
  default     = 30
}

variable "dlq_alarm_threshold" {
  description = "Number of DLQ messages that triggers an alarm"
  type        = number
  default     = 1
}

variable "tags" {
  description = "Tags applied to all resources"
  type        = map(string)
  default     = {}
}
