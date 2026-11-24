terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.73"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  # Remote state in S3. Bucket/key/region come from envs/<env>.backend.hcl:
  #   terraform init -backend-config=envs/staging.backend.hcl
  # use_lockfile = native S3 state locking (Terraform >= 1.10), no DynamoDB table needed.
  backend "s3" {
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region = var.aws_region

  # Every resource gets these tags -> cost reports per project/environment
  default_tags {
    tags = {
      Project     = var.project
      Environment = var.environment
      ManagedBy   = "terraform"
      Repository  = "aws-devops-platform"
    }
  }
}
