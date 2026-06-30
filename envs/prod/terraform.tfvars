environment = "prod"
aws_region  = "eu-west-1"

# Networking
vpc_cidr             = "10.2.0.0/16"
public_subnet_cidrs  = ["10.2.0.0/24", "10.2.1.0/24"]
private_subnet_cidrs = ["10.2.10.0/24", "10.2.11.0/24"]

# ECS
backend_image_uri = "123456789012.dkr.ecr.eu-west-1.amazonaws.com/agora-backend:latest"
ecs_cpu           = 1024
ecs_memory        = 2048
ecs_min_capacity  = 2
ecs_max_capacity  = 20
ecs_cpu_target    = 60

# RDS
rds_instance_class        = "db.t3.large"
rds_allocated_storage     = 100
rds_backup_retention_days = 7

# DNS / ACM
hosted_zone_name = "agora.example.com" # domain resolved: agora.example.com

# S3
frontend_bucket_name = "agora-frontend-prod"

# SES
ses_sender_email = "noreply@agora.example.com"

# Observability
cloudwatch_log_retention_days = 90
dlq_alarm_threshold           = 1
