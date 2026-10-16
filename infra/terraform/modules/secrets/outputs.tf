output "kms_key_arn" {
  description = "ARN of the customer managed KMS key for secrets"
  value       = aws_kms_key.secrets.arn
}

output "kms_key_id" {
  description = "ID of the customer managed KMS key for secrets"
  value       = aws_kms_key.secrets.key_id
}

output "jwt_signing_key_secret_arn" {
  description = "ARN of the Secrets Manager secret for JWT signing keys"
  value       = aws_secretsmanager_secret.jwt_signing_key.arn
}

output "jwt_signing_key_secret_name" {
  description = "Name of the Secrets Manager secret for JWT signing keys"
  value       = aws_secretsmanager_secret.jwt_signing_key.name
}

output "third_party_api_keys_secret_arn" {
  description = "ARN of the Secrets Manager secret for third-party API keys"
  value       = aws_secretsmanager_secret.third_party_api_keys.arn
}

output "third_party_api_keys_secret_name" {
  description = "Name of the Secrets Manager secret for third-party API keys"
  value       = aws_secretsmanager_secret.third_party_api_keys.name
}

output "cloudfront_signing_private_key_secret_arn" {
  description = "ARN of the Secrets Manager secret for CloudFront private signing key"
  value       = aws_secretsmanager_secret.cloudfront_signing_private_key.arn
}

output "secrets_read_policy_arn" {
  description = "ARN of the IAM policy granting read access to managed secrets"
  value       = aws_iam_policy.secrets_read_access.arn
}
