terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0, < 7.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "bucket" {
  source        = "./modules/s3_bucket"
  bucket_prefix = var.bucket_prefix

  tags = {
    Environment = var.environment
    Lesson      = "4-4"
  }
}
