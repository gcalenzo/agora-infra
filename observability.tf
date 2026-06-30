# CloudWatch log groups, metric alarms (golden signals + DLQ), and dashboard.
# alb_arn_suffix is the short suffix used by CloudWatch ALB metrics (not the full ARN).

module "observability" {
  source = "./modules/observability"

  name_prefix         = local.name_prefix
  ecs_cluster_name    = module.ecs_cluster.cluster_name
  ecs_service_name    = aws_ecs_service.backend.name
  alb_arn_suffix      = module.alb.arn_suffix
  rds_identifier      = module.rds.db_instance_identifier
  aws_region          = data.aws_region.current.name
  dlq_name            = aws_sqs_queue.dlq.name
  log_retention_days  = var.cloudwatch_log_retention_days
  dlq_alarm_threshold = var.dlq_alarm_threshold
  tags                = local.common_tags
}
