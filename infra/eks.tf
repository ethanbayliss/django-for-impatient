locals {
  name = substr(terraform.workspace, 6, 27)
}

module "eks_blueprints" {
  source = "git::https://github.com/aws-ia/terraform-aws-eks-blueprints.git?ref=v4.12.2"

  cluster_name    = local.name
  cluster_version = "1.23"

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets

  platform_teams = {
    ethan = {
      users = [
        "arn:aws:iam::619425392361:role/aws-reserved/sso.amazonaws.com/ap-southeast-2/AWSReservedSSO_AdministratorAccess_15343063ce262644"
      ]
    }
  }

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
      }]
      subnet_ids = module.vpc.private_subnets
    }
    # Providing compute for kube-system namespace where core addons reside
    kube_system = {
      fargate_profile_name = "kube-system"
      fargate_profile_namespaces = [
        {
          namespace = "kube-system"
      }]
      subnet_ids = module.vpc.private_subnets
    }
    # Sample application
    app = {
      fargate_profile_name = "app-wildcard"
      fargate_profile_namespaces = [
        {
          namespace = "app-*"
      }]
      subnet_ids = module.vpc.private_subnets
    }
  }

  tags = {
    Environment = var.environment
    DeployedBy  = "Terraform"
    GithubRepo = "django-for-impatient"
    GithubOrg  = "ethanbayliss"
  }
}


