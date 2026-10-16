terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# --- KMS Customer Managed Key for Secrets (§12.1) ---

resource "aws_kms_key" "secrets" {
  description             = "KMS CMK for encrypting secrets and JWT keys (${var.name_prefix}-${var.environment})"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = merge(var.tags, {
    Name        = "${var.name_prefix}-${var.environment}-secrets-kms"
    Environment = var.environment
  })
}

resource "aws_kms_alias" "secrets" {
  name          = "alias/${var.name_prefix}-${var.environment}-secrets"
  target_key_id = aws_kms_key.secrets.key_id
}

# --- JWT Signing Key Secret with Rotation Support (§8.3, §12.1) ---

resource "aws_secretsmanager_secret" "jwt_signing_key" {
  name        = "${var.name_prefix}/${var.environment}/jwt-signing-key"
  description = "JWT access token signing and verification keys (ES256/EdDSA, kid rotation §8.3, §12.1)"
  kms_key_id  = aws_kms_key.secrets.arn

  tags = merge(var.tags, {
    Name        = "${var.name_prefix}-${var.environment}-jwt-signing-key"
    Environment = var.environment
  })
}

resource "aws_secretsmanager_secret_version" "jwt_signing_key" {
  secret_id = aws_secretsmanager_secret.jwt_signing_key.id
  secret_string = jsonencode({
    kid             = var.jwt_key_id
    algorithm       = var.jwt_algorithm
    status          = "active"
    private_key_pem = var.jwt_private_key_pem
    public_key_pem  = var.jwt_public_key_pem
  })
}

# --- Third-Party Integration API Keys (§8.2, §12.1, §13) ---

resource "aws_secretsmanager_secret" "third_party_api_keys" {
  name        = "${var.name_prefix}/${var.environment}/third-party-api-keys"
  description = "Third-party integration API keys: SES email, RevenueCat, Apple/Google OIDC (§8.2, §12.1, §13)"
  kms_key_id  = aws_kms_key.secrets.arn

  tags = merge(var.tags, {
    Name        = "${var.name_prefix}-${var.environment}-third-party-api-keys"
    Environment = var.environment
  })
}

resource "aws_secretsmanager_secret_version" "third_party_api_keys" {
  secret_id = aws_secretsmanager_secret.third_party_api_keys.id
  secret_string = jsonencode({
    revenuecat_webhook_secret = var.revenuecat_webhook_secret
    email_provider_api_key    = var.email_provider_api_key
    google_oidc_client_secret = var.google_oidc_client_secret
    apple_oidc_client_secret  = var.apple_oidc_client_secret
  })
}

# --- CloudFront Private Signing Key for Premium Content URLs (§8.2, §12.1) ---

resource "aws_secretsmanager_secret" "cloudfront_signing_private_key" {
  name        = "${var.name_prefix}/${var.environment}/cloudfront-signing-key"
  description = "CloudFront private key for generating signed URLs for premium content (§8.2, §12.1)"
  kms_key_id  = aws_kms_key.secrets.arn

  tags = merge(var.tags, {
    Name        = "${var.name_prefix}-${var.environment}-cloudfront-signing-key"
    Environment = var.environment
  })
}

resource "aws_secretsmanager_secret_version" "cloudfront_signing_private_key" {
  secret_id = aws_secretsmanager_secret.cloudfront_signing_private_key.id
  secret_string = jsonencode({
    key_pair_id     = var.cloudfront_key_pair_id
    private_key_pem = var.cloudfront_signing_private_key_pem
  })
}

# --- IAM Policy for Backend Access to Secrets (§12.1) ---

data "aws_iam_policy_document" "secrets_read_access" {
  statement {
    sid    = "AllowSecretsManagerRead"
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
    ]
    resources = [
      aws_secretsmanager_secret.jwt_signing_key.arn,
      aws_secretsmanager_secret.third_party_api_keys.arn,
      aws_secretsmanager_secret.cloudfront_signing_private_key.arn,
    ]
  }

  statement {
    sid    = "AllowKMSDecryptForSecrets"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
    ]
    resources = [
      aws_kms_key.secrets.arn,
    ]
  }
}

resource "aws_iam_policy" "secrets_read_access" {
  name        = "${var.name_prefix}-${var.environment}-secrets-read-policy"
  description = "Policy allowing backend compute tasks to read application secrets and decrypt KMS keys"
  policy      = data.aws_iam_policy_document.secrets_read_access.json

  tags = merge(var.tags, {
    Name        = "${var.name_prefix}-${var.environment}-secrets-read-policy"
    Environment = var.environment
  })
}
