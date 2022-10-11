data "aws_caller_identity" "default" {}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.33.0"
    }
  }  
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "ethanbayliss"

    workspaces {
      prefix = "infra-django-for-impatient-"
    }
  }
}

provider "aws" {
  region = var.AWS_DEFAULT_REGION

  default_tags {
    tags = {
      Environment = var.environment
      DeployedBy  = "Terraform"
      GithubRepo = "django-for-impatient"
      GithubOrg  = "ethanbayliss"
    }
  }
}
