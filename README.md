# agora-infra

![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.10-7B42BC?logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-cloud-FF9900?logo=amazonaws&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green)

AWS infrastructure for **Agora** — a social-driven community platform where professionals publish content, follow each other, and receive curated newsletters.

Built with Terraform. Modular, portable, and production-ready.

---

## Architecture Overview

The infrastructure is built around three principles:

- **Security by design** — all workloads run in private subnets with no direct internet exposure; CloudFront is the single public entry point via VPC Origin
- **Scalability** — hybrid autoscaling (reactive CPU-based + scheduled pre-scaling) handles organic traffic growth and predictable newsletter-driven spikes
- **Observability** — CloudWatch monitors golden signals across all layers, with dedicated alerting on async task failures via DLQ

<!-- TODO: insert architecture diagram -->

### Component Map

| Layer | Service | Role |
|---|---|---|
| DNS | Route53 | Domain resolution |
| TLS | ACM | SSL certificate (CloudFront, must be in `us-east-1`) |
| CDN & Entry point | CloudFront | Single ingress for frontend and API; ALB reachable only via VPC Origin |
| Frontend | S3 | Static SPA assets served via CloudFront |
| Load Balancer | ALB | Internal; distributes API traffic to ECS tasks |
| Backend | ECS Fargate | Containerized backend in private subnets, with hybrid autoscaling |
| Container Registry | ECR | Docker images pulled by ECS at deploy/scale time |
| Database | RDS PostgreSQL | Primary + Read Replica; all in private subnets |
| Async Workers | SQS + Lambda + DLQ | Decoupled task execution with automatic retry and dead-letter |
| Newsletter Events | SES + EventBridge | Pre-scaling trigger: scales ECS before newsletter traffic arrives |
| Secrets | Secrets Manager | Credentials and sensitive config; accessed via IAM roles |
| Observability | CloudWatch | Metrics, logs, alarms, autoscaling policies |
| Identity | IAM | Least-privilege roles for all service-to-service interactions |

> **Note on VPC Endpoints**: in an enterprise context, VPC Endpoints for ECR and S3 are recommended to avoid routing Docker image pulls and S3 asset traffic through the NAT Gateway. They are intentionally omitted from this codebase for brevity, not for technical reasons.

---

## Module Structure

```
agora-infra/
├── modules/
│   ├── cloudfront/       # Custom: CloudFront with S3 origin + VPC Origin (private ALB)
│   ├── async_workers/    # Custom: Lambda worker + prescaler, EventBridge pre-scaling rule
│   └── observability/    # Custom: CloudWatch dashboards, alarms, golden signals
├── envs/
│   ├── dev/
│   │   ├── terraform.tfvars  # Dev variable overrides
│   │   └── backend.hcl       # Dev backend config (bucket, key, region)
│   ├── staging/
│   │   ├── terraform.tfvars
│   │   └── backend.hcl
│   └── prod/
│       ├── terraform.tfvars
│       └── backend.hcl
├── main.tf               # Module composition
├── variables.tf          # Input variable declarations
├── outputs.tf            # Root outputs
├── locals.tf             # Derived values and naming conventions
├── data.tf               # Data sources (caller identity, AZs, region)
├── providers.tf          # AWS provider config (default + us-east-1 alias for ACM)
├── backend.tf            # S3 remote state backend
└── versions.tf           # Terraform and provider version constraints
```

Three modules are custom-built; the rest delegate to well-maintained public modules from [terraform-aws-modules](https://registry.terraform.io/namespaces/terraform-aws-modules):

| Component | Public module | Version |
|---|---|---|
| VPC, subnets, NAT Gateway | `terraform-aws-modules/vpc/aws` | `~> 5.0` |
| ECS Fargate cluster | `terraform-aws-modules/ecs/aws` | `~> 5.0` |
| Application Load Balancer | `terraform-aws-modules/alb/aws` | `~> 9.0` |
| RDS PostgreSQL | `terraform-aws-modules/rds/aws` | `~> 6.0` |

The `cloudfront` module is custom because VPC Origin (private ALB as CloudFront origin) is not fully supported by available community modules.

---

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.10
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) configured with appropriate credentials
- [terraform-docs](https://terraform-docs.io) for regenerating module documentation
- An S3 bucket for Terraform remote state — no DynamoDB required (S3 native locking via `use_lockfile = true`)
- An ACM certificate provisioned in `us-east-1` for CloudFront (must exist before applying)

---

## State Backend Setup

Before the first `terraform init`, create the S3 bucket used for remote state.

This project uses **S3 native locking** (`use_lockfile = true`), available since Terraform 1.10. A `.tflock` file is created directly in the bucket on each operation — no DynamoDB table required.

All environments share a single bucket (`agora-tfstate`), with per-environment isolation via key path: `agora-infra/<env>/terraform.tfstate`. Backend config per environment lives in `envs/<env>/backend.hcl`.

```bash
# Create the shared state bucket
aws s3api create-bucket \
  --bucket agora-tfstate \
  --region eu-west-1 \
  --create-bucket-configuration LocationConstraint=eu-west-1

# Enable versioning (allows state history and recovery)
aws s3api put-bucket-versioning \
  --bucket agora-tfstate \
  --versioning-configuration Status=Enabled

# Block all public access
aws s3api put-public-access-block \
  --bucket agora-tfstate \
  --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
```

---

## Getting Started

### 1. Initialize

```bash
terraform init -backend-config="envs/dev/backend.hcl"
```

### 2. Plan

```bash
terraform plan -var-file="envs/dev/terraform.tfvars"
```

### 3. Apply

```bash
terraform apply -var-file="envs/prod/terraform.tfvars"
```

---

## Environments

| Environment | Purpose |
|---|---|
| `dev` | Development and feature testing |
| `staging` | Pre-production validation |
| `prod` | Production workload |

Each environment overrides variables such as ECS task sizes, min/max capacity, RDS instance class, and log retention periods via its own `.tfvars` file.

---

## Inputs / Outputs

> Auto-generated by [terraform-docs](https://terraform-docs.io). Run `make docs` to regenerate.

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
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.100.0 |
| <a name="provider_aws.us_east_1"></a> [aws.us\_east\_1](#provider\_aws.us\_east\_1) | 5.100.0 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_alb"></a> [alb](#module\_alb) | terraform-aws-modules/alb/aws | ~> 9.0 |
| <a name="module_async_workers"></a> [async\_workers](#module\_async\_workers) | ./modules/async_workers | n/a |
| <a name="module_cloudfront"></a> [cloudfront](#module\_cloudfront) | ./modules/cloudfront | n/a |
| <a name="module_ecs_cluster"></a> [ecs\_cluster](#module\_ecs\_cluster) | terraform-aws-modules/ecs/aws | ~> 5.0 |
| <a name="module_observability"></a> [observability](#module\_observability) | ./modules/observability | n/a |
| <a name="module_rds"></a> [rds](#module\_rds) | terraform-aws-modules/rds/aws | ~> 6.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | ~> 5.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_appautoscaling_policy.ecs_cpu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_target.ecs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
| [aws_db_instance.read_replica](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) | resource |
| [aws_ecs_service.backend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.backend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_iam_role.ecs_task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.ecs_task_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.ecs_task_app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.ecs_task_execution_secrets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.ecs_task_execution_managed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_route53_record.cloudfront_alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_s3_bucket.frontend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_public_access_block.frontend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.frontend](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_security_group.ecs_tasks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_sqs_queue.dlq](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [aws_sqs_queue.tasks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [aws_sqs_queue_redrive_allow_policy.dlq](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue_redrive_allow_policy) | resource |
| [aws_vpc_security_group_egress_rule.ecs_all_outbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.ecs_from_alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.rds_from_ecs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_acm_certificate.cloudfront](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/acm_certificate) | data source |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_route53_zone.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region for all resources | `string` | `"eu-west-1"` | no |
| <a name="input_backend_image_uri"></a> [backend\_image\_uri](#input\_backend\_image\_uri) | ECR image URI for the backend container (e.g. 123456789.dkr.ecr.eu-west-1.amazonaws.com/agora-backend:latest) | `string` | n/a | yes |
| <a name="input_cloudwatch_log_retention_days"></a> [cloudwatch\_log\_retention\_days](#input\_cloudwatch\_log\_retention\_days) | Number of days to retain CloudWatch log groups | `number` | `30` | no |
| <a name="input_container_port"></a> [container\_port](#input\_container\_port) | Port exposed by the backend container | `number` | `8000` | no |
| <a name="input_dlq_alarm_threshold"></a> [dlq\_alarm\_threshold](#input\_dlq\_alarm\_threshold) | Number of messages in DLQ that triggers an alarm | `number` | `1` | no |
| <a name="input_ecs_cpu"></a> [ecs\_cpu](#input\_ecs\_cpu) | vCPU units allocated to each ECS task (1024 = 1 vCPU) | `number` | `512` | no |
| <a name="input_ecs_cpu_target"></a> [ecs\_cpu\_target](#input\_ecs\_cpu\_target) | Target CPU utilization percentage for reactive autoscaling | `number` | `60` | no |
| <a name="input_ecs_max_capacity"></a> [ecs\_max\_capacity](#input\_ecs\_max\_capacity) | Maximum number of running ECS tasks | `number` | `10` | no |
| <a name="input_ecs_memory"></a> [ecs\_memory](#input\_ecs\_memory) | Memory allocated to each ECS task in MiB | `number` | `1024` | no |
| <a name="input_ecs_min_capacity"></a> [ecs\_min\_capacity](#input\_ecs\_min\_capacity) | Minimum number of running ECS tasks | `number` | `1` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Deployment environment | `string` | n/a | yes |
| <a name="input_frontend_bucket_name"></a> [frontend\_bucket\_name](#input\_frontend\_bucket\_name) | Name of the S3 bucket hosting the SPA frontend assets | `string` | n/a | yes |
| <a name="input_health_check_path"></a> [health\_check\_path](#input\_health\_check\_path) | HTTP path used by the ALB target group health check | `string` | `"/health/"` | no |
| <a name="input_hosted_zone_name"></a> [hosted\_zone\_name](#input\_hosted\_zone\_name) | Route53 hosted zone name (e.g. agora.example.com). The full domain is derived from this: prod uses the zone name directly, other environments prepend the environment name. | `string` | n/a | yes |
| <a name="input_pre_scale_count"></a> [pre\_scale\_count](#input\_pre\_scale\_count) | ECS desired task count set by the pre-scaler Lambda before a newsletter send | `number` | `5` | no |
| <a name="input_private_subnet_cidrs"></a> [private\_subnet\_cidrs](#input\_private\_subnet\_cidrs) | CIDR blocks for private subnets (one per AZ, used for all workloads) | `list(string)` | <pre>[<br/>  "10.0.10.0/24",<br/>  "10.0.11.0/24"<br/>]</pre> | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Project name, used as prefix for all resource names | `string` | `"agora"` | no |
| <a name="input_public_subnet_cidrs"></a> [public\_subnet\_cidrs](#input\_public\_subnet\_cidrs) | CIDR blocks for public subnets (one per AZ, used only for NAT Gateway) | `list(string)` | <pre>[<br/>  "10.0.0.0/24",<br/>  "10.0.1.0/24"<br/>]</pre> | no |
| <a name="input_rds_allocated_storage"></a> [rds\_allocated\_storage](#input\_rds\_allocated\_storage) | Allocated storage for RDS in GB | `number` | `20` | no |
| <a name="input_rds_backup_retention_days"></a> [rds\_backup\_retention\_days](#input\_rds\_backup\_retention\_days) | Number of days to retain automated RDS backups | `number` | `7` | no |
| <a name="input_rds_instance_class"></a> [rds\_instance\_class](#input\_rds\_instance\_class) | RDS instance class for the primary database | `string` | `"db.t3.medium"` | no |
| <a name="input_ses_sender_email"></a> [ses\_sender\_email](#input\_ses\_sender\_email) | Verified SES sender address used for newsletter delivery (triggers EventBridge pre-scaling) | `string` | n/a | yes |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | CIDR block for the VPC | `string` | `"10.0.0.0/16"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_alb_dns_name"></a> [alb\_dns\_name](#output\_alb\_dns\_name) | Internal ALB DNS name — not publicly accessible, reachable only via CloudFront VPC Origin |
| <a name="output_cloudfront_distribution_domain"></a> [cloudfront\_distribution\_domain](#output\_cloudfront\_distribution\_domain) | CloudFront distribution domain name (use as CNAME target in Route53) |
| <a name="output_dlq_url"></a> [dlq\_url](#output\_dlq\_url) | Dead Letter Queue URL — messages here have exhausted all retry attempts |
| <a name="output_ecs_cluster_name"></a> [ecs\_cluster\_name](#output\_ecs\_cluster\_name) | ECS cluster name |
| <a name="output_rds_endpoint"></a> [rds\_endpoint](#output\_rds\_endpoint) | RDS primary instance endpoint (write) |
| <a name="output_rds_read_replica_endpoint"></a> [rds\_read\_replica\_endpoint](#output\_rds\_read\_replica\_endpoint) | RDS read replica endpoint (read-heavy queries) |
| <a name="output_sqs_queue_url"></a> [sqs\_queue\_url](#output\_sqs\_queue\_url) | SQS queue URL for async task messages |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | VPC ID |
<!-- END_TF_DOCS -->

---

## Contributing

1. Branch from `main`
2. Follow the [Terraform style guide](https://developer.hashicorp.com/terraform/language/style)
3. Run `terraform fmt -recursive` and `terraform validate` before opening a PR
4. Regenerate docs with `terraform-docs markdown table --output-file README.md --output-mode inject .`

---

## License

MIT
