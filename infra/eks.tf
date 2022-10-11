locals {
  name            = "django-for-impatient"
  cluster_version = "1.23"
  region          = var.AWS_DEFAULT_REGION
}

################################################################################
# EKS Module
################################################################################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.30.0"

  cluster_name                    = local.name
  cluster_version                 = local.cluster_version
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  manage_aws_auth_configmap = true
  aws_auth_roles = [
    {
      rolearn  = var.eks_sso_admin_role_arn
      username = "eks_sso_admin_role_arn"
      groups   = ["system:masters"]
    },
  ]

  cluster_addons = {
    # Note: https://docs.aws.amazon.com/eks/latest/userguide/fargate-getting-started.html#fargate-gs-coredns
    coredns = {
      resolve_conflicts = "OVERWRITE"
      addon_version     = "v1.8.7-eksbuild.3"
    }
    kube-proxy = {
      resolve_conflicts = "OVERWRITE"
      addon_version     = "v1.23.8-eksbuild.2"
    }
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
      addon_version     = "v1.11.4-eksbuild.1"
    }
  }

  cluster_encryption_config = [{
    provider_key_arn = aws_kms_key.eks.arn
    resources        = ["secrets"]
  }]

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # You require a node group to schedule coredns which is critical for running correctly internal DNS.
  # If you want to use only fargate you must follow docs `(Optional) Update CoreDNS`
  # available under https://docs.aws.amazon.com/eks/latest/userguide/fargate-getting-started.html
  eks_managed_node_groups = {
    coredns = {
      desired_size = 2
      instance_types = ["t3.micro"]
      capacity_type  = "SPOT"

      # remote_access = {
      #   ec2_ssh_key               = aws_key_pair.bastion.id
      #   source_security_group_ids = [aws_security_group.bastion_sg.id]
      # }
    }
  }

  fargate_profiles = {
    default = {
      name = "default"
      selectors = [
        {
          namespace = "backend"
          labels = {
            Application = "backend"
          }
        },
        {
          namespace = "default"
          labels = {
            WorkerType = "fargate"
          }
        }
      ]

      timeouts = {
        create = "20m"
        delete = "20m"
      }
    }
  }
}

################################################################################
# Supporting Resources
################################################################################

resource "aws_kms_key" "eks" {
  description             = "EKS Secret Encryption Key"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

# resource "aws_key_pair" "bastion" {
#   public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDLrT2r6KuNJHf2nC/HOKFeMbpDwRPQtxp+WlNltNtKbh+akzQPU4tvE64Z2ocK8BvRjkdYmUexturtDON9m/M0t7jRdB1G+rzDKcX/oYJy04VQ9+XXT397yy3HC3h38QemQBQ0wQ5nNjF+OKft8hSfzilH73woaf/GGre5ba9RKPnEDWEn7U6j01tntugGbx2dhrQZ4KcREli19NZrLRxtZDrHD9S7e8bUZaNBLszospu46JM7PHx/tZ5sB+hHHbFh6Jz76/fr7boWuPQaZi6aBXLuXThaqW21O+PmbK2UUJhZRRVy1PbduuEham7sHQ+orU5e4bD10FAn0aEWtX1tcbI6MlUCQppK4H7wpN1YIvYE4CgqC1Exztjp/M7fXmuDrpSvShOc5N2UqKyV6B4n1VsZFp8RM0bfPFUqzhK2WL894xPTTMnzG+Sc74rrSAoyGcBVyPE4fh4+nukmy9q0G89ztY2bcgXlFPBHmNzvNEP3FR/dFdUnLlvE9fZ+icU="
# }

# resource "aws_instance" "bastion" {
#   ami           = data.aws_ami.ubuntu.id
#   instance_type = "t3.micro"

#   key_name               = aws_key_pair.bastion.key_name
#   subnet_id              = module.vpc.public_subnets[0]
#   vpc_security_group_ids = [aws_security_group.bastion_sg.id]
#   tags = {
#     Name = "bastion"
#   }
# }
