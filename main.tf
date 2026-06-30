# Infrastructure entry point.
#
# Each service or logical group is defined in its own file:
#   vpc.tf            — terraform-aws-modules/vpc/aws
#   alb.tf            — terraform-aws-modules/alb/aws
#   ecs.tf            — terraform-aws-modules/ecs/aws + service + autoscaling
#   rds.tf            — terraform-aws-modules/rds/aws + read replica
#   s3.tf             — S3 frontend bucket
#   dns.tf            — Route53 + ACM data sources + alias record
#   cloudfront.tf     — custom CloudFront module (VPC Origin)
#   async_workers.tf  — custom async workers module (SQS + Lambda + DLQ + EventBridge)
#   observability.tf  — custom observability module (CloudWatch)
