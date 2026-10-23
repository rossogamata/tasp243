terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0, < 7.0"
    }
  }
}

resource "aws_s3_bucket" "this" {
  bucket_prefix = var.bucket_prefix
  tags           = var.tags
}
