# Internal ALB, reachable only via CloudFront VPC Origin (not directly from internet).
#
# ALB SG egress uses VPC CIDR (not ECS SG reference) to avoid circular dependency:
#   ALB SG has no reference to ECS SG
#   ECS SG ingress references ALB SG (one-way dependency, no cycle)

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 9.0"

  name     = "${local.name_prefix}-alb"
  vpc_id   = module.vpc.vpc_id
  subnets  = module.vpc.private_subnets
  internal = true

  security_group_ingress_rules = {
    vpc_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      description = "HTTP from VPC (CloudFront VPC Origin)"
      cidr_ipv4   = module.vpc.vpc_cidr_block
    }
  }

  security_group_egress_rules = {
    to_ecs = {
      from_port   = var.container_port
      to_port     = var.container_port
      ip_protocol = "tcp"
      description = "Forward to ECS backend tasks"
      cidr_ipv4   = module.vpc.vpc_cidr_block
    }
  }

  listeners = {
    http = {
      port     = 80
      protocol = "HTTP"
      forward = {
        target_group_key = "backend"
      }
    }
  }

  target_groups = {
    backend = {
      name              = "${local.name_prefix}-backend"
      backend_protocol  = "HTTP"
      backend_port      = var.container_port
      target_type       = "ip"
      # ECS registers targets dynamically — no static attachment needed
      create_attachment = false

      health_check = {
        enabled             = true
        path                = var.health_check_path
        healthy_threshold   = 2
        unhealthy_threshold = 3
        interval            = 30
        timeout             = 5
        matcher             = "200"
      }

      # Short drain window for fast rolling deploys
      deregistration_delay = 30
    }
  }

  tags = local.common_tags
}
