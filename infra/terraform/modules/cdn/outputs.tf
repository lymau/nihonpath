output "cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.main.id
}

output "cloudfront_distribution_arn" {
  description = "ARN of the CloudFront distribution"
  value       = aws_cloudfront_distribution.main.arn
}

output "cloudfront_distribution_domain_name" {
  description = "Domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.main.domain_name
}

output "cloudfront_key_group_id" {
  description = "ID of the CloudFront key group for signed URLs"
  value       = aws_cloudfront_key_group.premium_signers.id
}

output "cloudfront_oac_id" {
  description = "ID of the CloudFront Origin Access Control"
  value       = aws_cloudfront_origin_access_control.s3_oac.id
}

output "logs_bucket_id" {
  description = "Name/ID of the S3 bucket storing CloudFront access logs"
  value       = aws_s3_bucket.logs.id
}
