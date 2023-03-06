terraform {
  required_version = "~> 1.3"

  required_providers {
    aws = {
      # https://registry.terraform.io/providers/hashicorp/aws/4.57.0/docs
      source = "hashicorp/aws"
      version = "~> 4.57"
    }
  }

  # Remote backend added after using the local backend.
  # State was migrated by 'terraform init'.
  backend "s3" {
    bucket = "jacquev6"
    key = "cloud-infrastructure/terraform.tfstate"
    region = "eu-west-3"
  }
}

provider "aws" {
  region  = "eu-west-3"
}
