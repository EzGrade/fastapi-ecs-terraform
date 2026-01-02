terraform {
  backend "s3" {
    bucket       = "fastapi-ecs-tf-state"
    key          = "fastapi-ecs/terraform.tfstate"
    use_lockfile = true
    region       = "eu-central-1"
    profile      = "personal"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}
