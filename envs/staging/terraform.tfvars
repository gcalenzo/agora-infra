environment = "staging"
aws_region  = "eu-west-1"

# Networking
vpc_cidr             = "10.1.0.0/16"
public_subnet_cidrs  = ["10.1.0.0/24", "10.1.1.0/24"]
private_subnet_cidrs = ["10.1.10.0/24", "10.1.11.0/24"]

# ECS
backend_image_uri = "123456789012.dkr.ecr.eu-west-1.amazonaws.com/agora-backend:staging"
ecs_cpu           = 512
ecs_memory        = 1024
ecs_min_capacity  = 1
ecs_max_capacity  = 5
ecs_cpu_target    = 65

# RDS
rds_instance_class        = "db.t3.medium"
rds_allocated_storage     = 20
rds_backup_retention_days = 3

# DNS / ACM
hosted_zone_name = "agora.example.com" # domain resolved: staging.agora.example.com

# S3
frontend_bucket_name = "agora-frontend-staging"

# SES
ses_sender_email = "noreply@staging.agora.example.com"

# Observability
cloudwatch_log_retention_days = 14
dlq_alarm_threshold           = 1
