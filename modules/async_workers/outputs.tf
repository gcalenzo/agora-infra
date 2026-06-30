output "queue_arn" {
  description = "SQS task queue ARN"
  value       = var.queue_arn
}

output "dlq_arn" {
  description = "Dead Letter Queue ARN"
  value       = var.dlq_arn
}

output "worker_function_name" {
  description = "Async worker Lambda function name"
  value       = aws_lambda_function.worker.function_name
}
