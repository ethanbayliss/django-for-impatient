locals {
  name = "django-for-impatient"
  tags = {
    Environment = var.environment
    DeployedBy  = "Terraform"
    GithubRepo = "django-for-impatient"
    GithubOrg  = "ethanbayliss"
  }
}

module "eks_blueprints" {
  source = "git::https://github.com/aws-ia/terraform-aws-eks-blueprints.git?ref=ac614b5a079055f9b18926597c55e8c6c9425263"

  cluster_name    = local.name
  cluster_version = "1.23"

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets

  map_roles = [
    {
      #rolearn must be modified to not include the "/aws-reserved/sso.amazonaws.com/ap-southeast-2" part
      rolearn  = "arn:aws:iam::619425392361:role/AWSReservedSSO_AdministratorAccess_15343063ce262644"
      username = "ops-role"
      groups   = ["system:masters"]
    }
  ]

  # https://github.com/aws-ia/terraform-aws-eks-blueprints/issues/485
  # https://github.com/aws-ia/terraform-aws-eks-blueprints/issues/494
  cluster_kms_key_additional_admin_arns = [data.aws_caller_identity.current.arn]

  fargate_profiles = {
    # Providing compute for default namespace
    default = {
      fargate_profile_name = "default"
      fargate_profile_namespaces = [
        {
          namespace = "default"
        },
      ]
      subnet_ids = module.vpc.private_subnets
    }
    # Providing compute for kube-system namespace where core addons reside
    kube_system = {
      fargate_profile_name = "kube-system"
      fargate_profile_namespaces = [
        {
          namespace = "kube-system"
        }
      ]
      subnet_ids = module.vpc.private_subnets
    }
  }

  tags = local.tags
}


