# Provider configuration
provider "aws" {
  region = var.aws_region
}

# Variables
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}

variable "environments" {
  description = "Environment configurations"
  type = map(object({
    cluster_version = string
    desired_size    = number
    min_size        = number
    max_size        = number
    instance_types  = list(string)
  }))
  default = {
    prod = {
      cluster_version = "1.30"
      desired_size    = 3
      min_size        = 2
      max_size        = 5
      instance_types  = ["t2.medium"]
    }
    staging = {
      cluster_version = "1.30"
      desired_size    = 1
      min_size        = 1
      max_size        = 3
      instance_types  = ["t2.small"]
    }
  }
}

# VPC Module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 4.0"

  for_each = var.environments

  name = "eks-vpc-${each.key}"
  cidr = each.key == "prod" ? "10.0.0.0/16" : "10.1.0.0/16"

  azs             = ["${var.aws_region}a", "${var.aws_region}b", "${var.aws_region}c"]
  private_subnets = each.key == "prod" ? ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"] : ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
  public_subnets  = each.key == "prod" ? ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"] : ["10.1.4.0/24", "10.1.5.0/24", "10.1.6.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = each.key == "staging" ? true : false

  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }

  tags = {
    Environment = each.key
    Terraform   = "true"
  }
}

# EKS Cluster
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  for_each = var.environments

  cluster_name                   = "go-leaf-${each.key}"
  cluster_version                = each.value.cluster_version
  cluster_endpoint_public_access = true

  vpc_id     = module.vpc[each.key].vpc_id
  subnet_ids = module.vpc[each.key].private_subnets

  eks_managed_node_groups = {
    main = {
      desired_size   = each.value.desired_size
      min_size       = each.value.min_size
      max_size       = each.value.max_size
      instance_types = each.value.instance_types
      capacity_type  = "ON_DEMAND"
    }
  }

  tags = {
    Environment = each.key
    Terraform   = "true"
  }
}

# Outputs
output "cluster_endpoints" {
  description = "Endpoint for each EKS cluster"
  value = {
    for k, v in module.eks : k => v.cluster_endpoint
  }
}

output "cluster_security_group_ids" {
  description = "Security group ID for each cluster control plane"
  value = {
    for k, v in module.eks : k => v.cluster_security_group_id
  }
}

output "cluster_iam_role_names" {
  description = "IAM role name for each cluster"
  value = {
    for k, v in module.eks : k => v.cluster_iam_role_name
  }
}
