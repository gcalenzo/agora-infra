output "dashboard_name" {
  description = "CloudWatch dashboard name"
  value       = aws_cloudwatch_dashboard.main.dashboard_name
}

output "dlq_alarm_arn" {
  description = "ARN of the DLQ CloudWatch alarm"
  value       = aws_cloudwatch_metric_alarm.dlq.arn
}

output "ecs_log_group_name" {
  description = "CloudWatch log group name for ECS backend tasks"
  value       = aws_cloudwatch_log_group.ecs_backend.name
}
