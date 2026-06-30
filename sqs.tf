# SQS queue and DLQ are defined here in the root rather than inside the
# async_workers module to avoid a circular dependency: ecs.tf needs the queue
# ARN for the ECS task role policy, while the async_workers module needs the
# ECS service name. Keeping SQS in the root breaks the cycle.

resource "aws_sqs_queue" "dlq" {
  name                      = "${local.name_prefix}-dlq"
  message_retention_seconds = 1209600 # 14 days — long retention for post-mortem analysis
  tags                      = local.common_tags
}

resource "aws_sqs_queue" "tasks" {
  name                       = "${local.name_prefix}-tasks"
  visibility_timeout_seconds = 300 # must be >= Lambda timeout to prevent double-processing

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = 3
  })

  tags = local.common_tags
}

# Restricts DLQ to only accept messages from the tasks queue
resource "aws_sqs_queue_redrive_allow_policy" "dlq" {
  queue_url = aws_sqs_queue.dlq.id

  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue"
    sourceQueueArns   = [aws_sqs_queue.tasks.arn]
  })
}
