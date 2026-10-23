output "bucket_name" {
  description = "Name of the created bucket."
  value       = aws_s3_bucket.this.id
}

output "bucket_arn" {
  description = "ARN of the created bucket."
  value       = aws_s3_bucket.this.arn
}
