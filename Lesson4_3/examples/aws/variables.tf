variable "aws_region" {
  description = "AWS region used for the lesson plan."
  type        = string
  default     = "us-east-1"
}

variable "bucket_prefix" {
  description = "Prefix for the globally unique S3 bucket name."
  type        = string
  default     = "terraform-lesson43-"
}
