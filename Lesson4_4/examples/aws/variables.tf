variable "aws_region" {
  description = "AWS region used for the lesson plan."
  type        = string
  default     = "us-east-1"
}

variable "bucket_prefix" {
  description = "Prefix for the globally unique S3 bucket name."
  type        = string
  default     = "terraform-lesson44-"
}

variable "environment" {
  description = "Environment name attached to the bucket as a tag."
  type        = string
  default     = "training"
}
