# Async task pipeline:  SQS → Lambda (worker) → DLQ
# Pre-scaling pipeline: SES send event → EventBridge → Lambda (pre-scaler)
#
# SQS queue and DLQ are created in root sqs.tf and passed as variables,
# avoiding a circular dependency with ecs.tf (which references the queue ARN).

# -----------------------------------------------------------------------------
# IAM — async worker Lambda
# -----------------------------------------------------------------------------

resource "aws_iam_role" "worker" {
  name_prefix = "${var.name_prefix}-worker-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "worker_basic" {
  role       = aws_iam_role.worker.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy" "worker_sqs" {
  name_prefix = "sqs-consume-"
  role        = aws_iam_role.worker.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes"
      ]
      Resource = var.queue_arn
    }]
  })
}

# -----------------------------------------------------------------------------
# Lambda — async worker (consumes from SQS)
# -----------------------------------------------------------------------------

data "archive_file" "worker" {
  type        = "zip"
  source_dir  = "${path.module}/src/worker"
  output_path = "${path.module}/builds/worker.zip"
}

resource "aws_lambda_function" "worker" {
  function_name    = "${var.name_prefix}-worker"
  role             = aws_iam_role.worker.arn
  runtime          = "python3.12"
  handler          = "handler.handler"
  filename         = data.archive_file.worker.output_path
  source_code_hash = data.archive_file.worker.output_base64sha256
  timeout          = 300
  memory_size      = 256

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [aws_security_group.lambda.id]
  }

  tags = var.tags
}

resource "aws_lambda_event_source_mapping" "sqs" {
  event_source_arn                   = var.queue_arn
  function_name                      = aws_lambda_function.worker.arn
  batch_size                         = 10
  maximum_batching_window_in_seconds = 30
  function_response_types            = ["ReportBatchItemFailures"]
}

# -----------------------------------------------------------------------------
# Security group for Lambda functions (VPC-attached)
# -----------------------------------------------------------------------------

resource "aws_security_group" "lambda" {
  name_prefix = "${var.name_prefix}-lambda-"
  description = "Lambda functions: egress to RDS, SQS, and internet via NAT"
  vpc_id      = var.vpc_id
  tags        = var.tags
  lifecycle { create_before_destroy = true }
}

resource "aws_vpc_security_group_egress_rule" "lambda_all_outbound" {
  security_group_id = aws_security_group.lambda.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
  description       = "Outbound: SQS, Secrets Manager via NAT; ECS API endpoint"
}

# -----------------------------------------------------------------------------
# IAM — pre-scaling Lambda
# -----------------------------------------------------------------------------

resource "aws_iam_role" "prescaler" {
  name_prefix = "${var.name_prefix}-prescaler-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "prescaler_basic" {
  role       = aws_iam_role.prescaler.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "prescaler_ecs" {
  name_prefix = "ecs-update-"
  role        = aws_iam_role.prescaler.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["ecs:UpdateService", "ecs:DescribeServices"]
      Resource = var.ecs_service_arn
    }]
  })
}

# -----------------------------------------------------------------------------
# Lambda — pre-scaler (sets ECS desired count before newsletter traffic arrives)
# -----------------------------------------------------------------------------

data "archive_file" "prescaler" {
  type        = "zip"
  source_dir  = "${path.module}/src/prescaler"
  output_path = "${path.module}/builds/prescaler.zip"
}

resource "aws_lambda_function" "prescaler" {
  function_name    = "${var.name_prefix}-prescaler"
  role             = aws_iam_role.prescaler.arn
  runtime          = "python3.12"
  handler          = "handler.handler"
  filename         = data.archive_file.prescaler.output_path
  source_code_hash = data.archive_file.prescaler.output_base64sha256
  timeout          = 30
  memory_size      = 128

  environment {
    variables = {
      ECS_CLUSTER_ARN  = var.ecs_cluster_arn
      ECS_SERVICE_NAME = var.ecs_service_name
      PRE_SCALE_COUNT  = var.pre_scale_count
    }
  }

  tags = var.tags
}

# -----------------------------------------------------------------------------
# EventBridge — SES send event → pre-scaler Lambda
# -----------------------------------------------------------------------------

resource "aws_cloudwatch_event_rule" "ses_send" {
  name        = "${var.name_prefix}-ses-newsletter-send"
  description = "Fires when SES delivers a newsletter batch, triggers ECS pre-scaling"

  event_pattern = jsonencode({
    source      = ["aws.ses"]
    detail-type = ["SES Email Sending Events"]
    detail = {
      eventType = ["Send"]
      mail = {
        source = [var.ses_sender_email]
      }
    }
  })

  tags = var.tags
}

resource "aws_cloudwatch_event_target" "prescaler" {
  rule = aws_cloudwatch_event_rule.ses_send.name
  arn  = aws_lambda_function.prescaler.arn
}

resource "aws_lambda_permission" "eventbridge_prescaler" {
  statement_id  = "AllowEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.prescaler.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.ses_send.arn
}
