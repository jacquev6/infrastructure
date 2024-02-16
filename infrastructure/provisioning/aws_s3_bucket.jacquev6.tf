# Created a long time ago in the AWS console.
# Imported into Terraform with:
#   terraform import aws_s3_bucket.jacquev6 jacquev6
#   terraform import aws_s3_bucket_public_access_block.jacquev6 jacquev6
# Tweaked using 'terraform plan' to match the current state.
resource "aws_s3_bucket" "jacquev6" {
  bucket = "jacquev6"

  tags = {} # Tab "Properties", section "Tags"
}

# See https://github.com/hashicorp/terraform-provider-aws/issues/23106 for more
# information about the plethora of additional resources required to configure a
# S3 bucket.

# Tab "Properties", section "Bucket Versioning"
resource "aws_s3_bucket_versioning" "jacquev6" {
  bucket = aws_s3_bucket.jacquev6.id

  versioning_configuration {
    status = "Disabled"
  }
}

# Tab "Properties", section "Default encryption"
resource "aws_s3_bucket_server_side_encryption_configuration" "jacquev6" {
  bucket = aws_s3_bucket.jacquev6.id

  rule {
    bucket_key_enabled = false
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Tab "Properties", section "Requester pays"
resource "aws_s3_bucket_request_payment_configuration" "jacquev6" {
  bucket = aws_s3_bucket.jacquev6.id
  payer  = "Requester"
}

# Tab "Properties", section "Website hosting"
# No resource "aws_s3_bucket_website_configuration"


# Tab "Permissions", section "Block public access (bucket settings)"
resource "aws_s3_bucket_public_access_block" "jacquev6" {
  bucket = aws_s3_bucket.jacquev6.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


# Tab "Management", section "Lifecycle rules"
# No resource "aws_s3_bucket_lifecycle_configuration"

# Tab "Management", section "Replication rules"
# No resource "aws_s3_bucket_replication_configuration"

# Tab "Management", section "Inventory configurations"
# No resource "aws_s3_bucket_inventory"


# Not yet investigated
# resource "aws_s3_bucket_intelligent_tiering_configuration" "jacquev6" {
#   bucket = aws_s3_bucket.jacquev6.id
# }
# resource "aws_s3_bucket_logging" "jacquev6" {
#   bucket = aws_s3_bucket.jacquev6.id
# }
# resource "aws_s3_bucket_accelerate_configuration" "jacquev6" {
#   bucket = aws_s3_bucket.jacquev6.id
# }
# resource "aws_s3_bucket_acl" "jacquev6" {
#   bucket = aws_s3_bucket.jacquev6.id
# }
# resource "aws_s3_bucket_analytics_configuration" "jacquev6" {
#   bucket = aws_s3_bucket.jacquev6.id
# }
# resource "aws_s3_bucket_cors_configuration" "jacquev6" {
#   bucket = aws_s3_bucket.jacquev6.id
# }
# resource "aws_s3_bucket_metric" "jacquev6" {
#   bucket = aws_s3_bucket.jacquev6.id
# }
# resource "aws_s3_bucket_notification" "jacquev6" {
#   bucket = aws_s3_bucket.jacquev6.id
# }
# resource "aws_s3_bucket_object_lock_configuration" "jacquev6" {
#   bucket = aws_s3_bucket.jacquev6.id
# }
# resource "aws_s3_bucket_ownership_controls" "jacquev6" {
#   bucket = aws_s3_bucket.jacquev6.id
# }
# resource "aws_s3_bucket_policy" "jacquev6" {
#   bucket = aws_s3_bucket.jacquev6.id
# }
