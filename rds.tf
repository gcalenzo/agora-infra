# RDS PostgreSQL primary + Read Replica.
# Password managed by Secrets Manager (manage_master_user_password = true), never in state.

# -----------------------------------------------------------------------------
# Security group
# -----------------------------------------------------------------------------

resource "aws_security_group" "rds" {
  name_prefix = "${local.name_prefix}-rds-"
  description = "RDS: PostgreSQL ingress from ECS tasks only"
  vpc_id      = module.vpc.vpc_id
  tags        = local.common_tags
  lifecycle { create_before_destroy = true }
}

resource "aws_vpc_security_group_ingress_rule" "rds_from_ecs" {
  security_group_id            = aws_security_group.rds.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.ecs_tasks.id
  description                  = "PostgreSQL from ECS tasks"
}

# -----------------------------------------------------------------------------
# RDS primary instance
# -----------------------------------------------------------------------------

module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 6.0"

  identifier = "${local.name_prefix}-db"

  engine            = "postgres"
  engine_version    = "15"
  instance_class    = var.rds_instance_class
  allocated_storage = var.rds_allocated_storage
  storage_type      = "gp3"
  storage_encrypted = true

  db_name  = "agora"
  username = "agora_admin"
  port     = 5432
  family   = "postgres15"

  # Password stored in Secrets Manager — never appears in state
  manage_master_user_password = true

  vpc_security_group_ids = [aws_security_group.rds.id]

  create_db_subnet_group = true
  subnet_ids             = module.vpc.private_subnets

  multi_az                = var.environment == "prod"
  backup_retention_period = var.rds_backup_retention_days
  skip_final_snapshot     = var.environment != "prod"
  deletion_protection     = var.environment == "prod"

  # Performance Insights for query-level observability
  performance_insights_enabled = true

  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# Read Replica — separates read traffic from writes
# replicate_source_db requires backup_retention_period > 0 on the primary
# -----------------------------------------------------------------------------

resource "aws_db_instance" "read_replica" {
  identifier             = "${local.name_prefix}-db-replica"
  replicate_source_db    = module.rds.db_instance_identifier
  instance_class         = var.rds_instance_class
  storage_encrypted      = true
  skip_final_snapshot    = true
  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.rds.id]

  tags = local.common_tags
}
