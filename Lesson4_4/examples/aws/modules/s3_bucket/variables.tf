variable "bucket_prefix" {
  description = "Prefix used to generate a unique S3 bucket name."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]*$", var.bucket_prefix))
    error_message = "Use lowercase letters, digits, and hyphens; the prefix must start with a lowercase letter or digit."
  }
}

variable "tags" {
  description = "Tags applied to the bucket."
  type        = map(string)
  default     = {}
}
