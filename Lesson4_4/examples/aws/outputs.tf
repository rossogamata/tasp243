output "bucket_name" {
  description = "Name of the lesson S3 bucket."
  value       = module.bucket.bucket_name
}

output "bucket_arn" {
  description = "ARN of the lesson S3 bucket."
  value       = module.bucket.bucket_arn
}
