terraform {
  required_version = "~> 1.3"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.57"
    }
  }
}

provider "aws" {
  region  = "eu-west-3"
}
