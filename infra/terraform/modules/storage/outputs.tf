output "content_packs_bucket_id" {
  description = "Name/ID of the content packs S3 bucket"
  value       = aws_s3_bucket.content_packs.id
}

output "content_packs_bucket_arn" {
  description = "ARN of the content packs S3 bucket"
  value       = aws_s3_bucket.content_packs.arn
}

output "content_packs_bucket_domain_name" {
  description = "Domain name of the content packs S3 bucket"
  value       = aws_s3_bucket.content_packs.bucket_domain_name
}

output "content_packs_bucket_regional_domain_name" {
  description = "Regional domain name of the content packs S3 bucket"
  value       = aws_s3_bucket.content_packs.bucket_regional_domain_name
}

output "audio_bucket_id" {
  description = "Name/ID of the audio S3 bucket"
  value       = aws_s3_bucket.audio.id
}

output "audio_bucket_arn" {
  description = "ARN of the audio S3 bucket"
  value       = aws_s3_bucket.audio.arn
}

output "audio_bucket_domain_name" {
  description = "Domain name of the audio S3 bucket"
  value       = aws_s3_bucket.audio.bucket_domain_name
}

output "audio_bucket_regional_domain_name" {
  description = "Regional domain name of the audio S3 bucket"
  value       = aws_s3_bucket.audio.bucket_regional_domain_name
}

output "presigned_url_policy_arn" {
  description = "ARN of the IAM policy granting read access for generating S3 presigned URLs"
  value       = aws_iam_policy.presigned_url_access.arn
}
