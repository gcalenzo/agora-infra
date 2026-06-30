variable "name_prefix" {
  description = "Prefix applied to all resource names"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for Lambda VPC configuration"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for the async worker Lambda"
  type        = list(string)
}

variable "queue_arn" {
  description = "ARN of the SQS task queue (created in root sqs.tf)"
  type        = string
}

variable "dlq_arn" {
  description = "ARN of the Dead Letter Queue (created in root sqs.tf)"
  type        = string
}

variable "ses_sender_email" {
  description = "Verified SES sender address; EventBridge listens for send events from this address"
  type        = string
}

variable "ecs_service_arn" {
  description = "ECS service ARN, used by the pre-scaling Lambda IAM policy"
  type        = string
}

variable "ecs_cluster_arn" {
  description = "ECS cluster ARN, passed as env var to the pre-scaling Lambda"
  type        = string
}

variable "ecs_service_name" {
  description = "ECS service name, passed as env var to the pre-scaling Lambda"
  type        = string
}

variable "pre_scale_count" {
  description = "ECS desired task count to set when a newsletter send is detected"
  type        = number
  default     = 5
}

variable "tags" {
  description = "Tags applied to all resources"
  type        = map(string)
  default     = {}
}
