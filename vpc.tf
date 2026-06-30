# VPC: public subnets for NAT Gateways only, all workloads in private subnets.
# All application resources (ECS, ALB, RDS, Lambda) run in private subnets.
# single_nat_gateway = true in non-prod reduces cost; prod uses one per AZ for HA.

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = local.name_prefix
  cidr = var.vpc_cidr

  azs             = slice(data.aws_availability_zones.available.names, 0, length(var.public_subnet_cidrs))
  public_subnets  = var.public_subnet_cidrs
  private_subnets = var.private_subnet_cidrs

  enable_nat_gateway   = true
  single_nat_gateway   = var.environment != "prod"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = local.common_tags
}
