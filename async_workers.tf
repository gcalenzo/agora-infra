# aws_ecs_service does not export an ARN attribute — the service ARN is
# constructed manually from known components (region, account, cluster, service).

module "async_workers" {
  source = "./modules/async_workers"

  name_prefix        = local.name_prefix
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets
  queue_arn          = aws_sqs_queue.tasks.arn
  dlq_arn            = aws_sqs_queue.dlq.arn
  ses_sender_email   = var.ses_sender_email
  ecs_service_arn    = "arn:aws:ecs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:service/${module.ecs_cluster.cluster_name}/${aws_ecs_service.backend.name}"
  ecs_cluster_arn    = module.ecs_cluster.cluster_arn
  ecs_service_name   = aws_ecs_service.backend.name
  pre_scale_count    = var.pre_scale_count
  tags               = local.common_tags
}
