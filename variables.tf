variable "project_name" {
  description = "Project name, used as prefix for all resource names"
  type        = string
  default     = "agora"
}

variable "environment" {
  description = "Deployment environment"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "eu-west-1"
}

# --- Networking ---

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (one per AZ, used only for NAT Gateway)"
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets (one per AZ, used for all workloads)"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

# --- ECS ---

variable "backend_image_uri" {
  description = "ECR image URI for the backend container (e.g. 123456789.dkr.ecr.eu-west-1.amazonaws.com/agora-backend:latest)"
  type        = string
}

variable "container_port" {
  description = "Port exposed by the backend container"
  type        = number
  default     = 8000
}

variable "ecs_cpu" {
  description = "vCPU units allocated to each ECS task (1024 = 1 vCPU)"
  type        = number
  default     = 512
}

variable "ecs_memory" {
  description = "Memory allocated to each ECS task in MiB"
  type        = number
  default     = 1024
}

variable "ecs_min_capacity" {
  description = "Minimum number of running ECS tasks"
  type        = number
  default     = 1
}

variable "ecs_max_capacity" {
  description = "Maximum number of running ECS tasks"
  type        = number
  default     = 10
}

variable "ecs_cpu_target" {
  description = "Target CPU utilization percentage for reactive autoscaling"
  type        = number
  default     = 60
}

# --- RDS ---

variable "rds_instance_class" {
  description = "RDS instance class for the primary database"
  type        = string
  default     = "db.t3.medium"
}

variable "rds_allocated_storage" {
  description = "Allocated storage for RDS in GB"
  type        = number
  default     = 20
}

variable "rds_backup_retention_days" {
  description = "Number of days to retain automated RDS backups"
  type        = number
  default     = 7
}

# --- DNS / ACM ---

variable "hosted_zone_name" {
  description = "Route53 hosted zone name (e.g. agora.example.com). The full domain is derived from this: prod uses the zone name directly, other environments prepend the environment name."
  type        = string
}


# --- S3 ---

variable "frontend_bucket_name" {
  description = "Name of the S3 bucket hosting the SPA frontend assets"
  type        = string
}

# --- SES ---

variable "ses_sender_email" {
  description = "Verified SES sender address used for newsletter delivery (triggers EventBridge pre-scaling)"
  type        = string
}

# --- ALB ---

variable "health_check_path" {
  description = "HTTP path used by the ALB target group health check"
  type        = string
  default     = "/health/"
}

# --- Async workers ---

variable "pre_scale_count" {
  description = "ECS desired task count set by the pre-scaler Lambda before a newsletter send"
  type        = number
  default     = 5
}

# --- Observability ---

variable "cloudwatch_log_retention_days" {
  description = "Number of days to retain CloudWatch log groups"
  type        = number
  default     = 30
}

variable "dlq_alarm_threshold" {
  description = "Number of messages in DLQ that triggers an alarm"
  type        = number
  default     = 1
}
