environment = "dev"
aws_region  = "eu-west-1"

# Networking
vpc_cidr             = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.0.0/24", "10.0.1.0/24"]
private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]

# ECS
backend_image_uri = "123456789012.dkr.ecr.eu-west-1.amazonaws.com/agora-backend:dev"
ecs_cpu           = 256
ecs_memory        = 512
ecs_min_capacity  = 1
ecs_max_capacity  = 3
ecs_cpu_target    = 70

# RDS
rds_instance_class        = "db.t3.small"
rds_allocated_storage     = 20
rds_backup_retention_days = 1

# DNS / ACM
hosted_zone_name = "agora.example.com" # domain resolved: dev.agora.example.com

# S3
frontend_bucket_name = "agora-frontend-dev"

# SES
ses_sender_email = "noreply@dev.agora.example.com"

# Observability
cloudwatch_log_retention_days = 7
dlq_alarm_threshold           = 1
