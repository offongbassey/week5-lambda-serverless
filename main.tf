terraform {
    required_version = "> = 1.0"

    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 5.0"
        }
    }
}

provider "aws" {
    region = var.aws_region

    default_tags {
        tags = {
            Project     = "var.project_name"
            Environment = "dev"
            ManagedBy   = Terraform"

        }
    }
}

# Create S3 bucket that will trigger Lambda
resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "${var.project_name}-uploads-${data.aws_caller_identity.current.account_id}"
}

# Get current AWS account ID
data "aws_caller_identity" "current" {}

# Enable versioning for the bucket
resource "aws_s3_bucket_versioning" "lambda_bucket_versioning" {
  bucket = aws_s3_bucket.lambda_bucket.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

# Block all public access
resource "aws_s3_bucket_public_access_block" "lambda_bucket_pab" {
  bucket = aws_s3_bucket.lambda_bucket.id
  
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}