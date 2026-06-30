# module: async_workers

Async task pipeline and pre-scaling trigger.

**Async pipeline**: SQS queue consumed by a Lambda function. Messages that exceed the maximum receive count are moved to a Dead Letter Queue (DLQ) for post-mortem analysis and alerting.

**Pre-scaling**: an EventBridge rule listens for SES newsletter send events and invokes a dedicated Lambda that updates the ECS desired count before the traffic spike arrives.

## Lambda packaging

Lambda source code lives in `src/worker/` and `src/prescaler/`. The `archive_file` data source packages them into zips at plan time (written to `builds/`, which is gitignored).

> **Note:** This local packaging approach is used for demo purposes. In production, the CI/CD pipeline builds, tests, and publishes versioned zips to S3; Terraform references them via `s3_bucket`/`s3_key`/`s3_object_version`, decoupling Lambda deploys from infrastructure changes.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10 |
| <a name="requirement_archive"></a> [archive](#requirement\_archive) | ~> 2.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_archive"></a> [archive](#provider\_archive) | ~> 2.0 |
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_cloudwatch_event_rule.ses_send](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.prescaler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_iam_role.prescaler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.worker](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.prescaler_ecs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.worker_sqs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.prescaler_basic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.worker_basic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_event_source_mapping.sqs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_event_source_mapping) | resource |
| [aws_lambda_function.prescaler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_function.worker](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.eventbridge_prescaler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_security_group.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_security_group_egress_rule.lambda_all_outbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [archive_file.prescaler](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [archive_file.worker](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_dlq_arn"></a> [dlq\_arn](#input\_dlq\_arn) | ARN of the Dead Letter Queue (created in root sqs.tf) | `string` | n/a | yes |
| <a name="input_ecs_cluster_arn"></a> [ecs\_cluster\_arn](#input\_ecs\_cluster\_arn) | ECS cluster ARN, passed as env var to the pre-scaling Lambda | `string` | n/a | yes |
| <a name="input_ecs_service_arn"></a> [ecs\_service\_arn](#input\_ecs\_service\_arn) | ECS service ARN, used by the pre-scaling Lambda IAM policy | `string` | n/a | yes |
| <a name="input_ecs_service_name"></a> [ecs\_service\_name](#input\_ecs\_service\_name) | ECS service name, passed as env var to the pre-scaling Lambda | `string` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix applied to all resource names | `string` | n/a | yes |
| <a name="input_pre_scale_count"></a> [pre\_scale\_count](#input\_pre\_scale\_count) | ECS desired task count to set when a newsletter send is detected | `number` | `5` | no |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | Private subnet IDs for the async worker Lambda | `list(string)` | n/a | yes |
| <a name="input_queue_arn"></a> [queue\_arn](#input\_queue\_arn) | ARN of the SQS task queue (created in root sqs.tf) | `string` | n/a | yes |
| <a name="input_ses_sender_email"></a> [ses\_sender\_email](#input\_ses\_sender\_email) | Verified SES sender address; EventBridge listens for send events from this address | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to all resources | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID for Lambda VPC configuration | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_dlq_arn"></a> [dlq\_arn](#output\_dlq\_arn) | Dead Letter Queue ARN |
| <a name="output_queue_arn"></a> [queue\_arn](#output\_queue\_arn) | SQS task queue ARN |
| <a name="output_worker_function_name"></a> [worker\_function\_name](#output\_worker\_function\_name) | Async worker Lambda function name |
<!-- END_TF_DOCS -->
