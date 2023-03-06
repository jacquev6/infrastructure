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

# Created a long time ago in the AWS console.
# Imported into Terraform with:
#   terraform import aws_s3_bucket.jacquev6 jacquev6
#   terraform import aws_s3_bucket_public_access_block.jacquev6 jacquev6
# Tweaked using 'terraform plan' to match the current state.
resource "aws_s3_bucket" "jacquev6" {
  bucket = "jacquev6"
}
resource "aws_s3_bucket_public_access_block" "jacquev6" {
  bucket = aws_s3_bucket.jacquev6.id

  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}
