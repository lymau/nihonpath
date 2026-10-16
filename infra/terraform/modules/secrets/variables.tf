variable "name_prefix" {
  description = "Prefix applied to all resource names"
  type        = string
  default     = "nihonpath"
}

variable "environment" {
  description = "Target deployment environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "jwt_key_id" {
  description = "Key identifier (kid) for JWT signing key supporting rotation (§8.3)"
  type        = string
  default     = "nihonpath-dev-jwt-v1"
}

variable "jwt_algorithm" {
  description = "Algorithm for JWT signing (ES256 or EdDSA §8.3)"
  type        = string
  default     = "ES256"
}

variable "jwt_private_key_pem" {
  description = "Private key PEM for JWT signing"
  type        = string
  sensitive   = true
  default     = "placeholder-jwt-private-key-for-dev"
}

variable "jwt_public_key_pem" {
  description = "Public key PEM for JWT verification (JWKS /.well-known/jwks.json §8.3)"
  type        = string
  default     = "placeholder-jwt-public-key-for-dev"
}

variable "revenuecat_webhook_secret" {
  description = "Shared authorization header secret for RevenueCat webhooks (§13)"
  type        = string
  sensitive   = true
  default     = "placeholder-revenuecat-webhook-secret-dev"
}

variable "email_provider_api_key" {
  description = "API key for transactional email provider (SES / Postmark §8.3)"
  type        = string
  sensitive   = true
  default     = "placeholder-email-provider-key-dev"
}

variable "google_oidc_client_secret" {
  description = "Client secret for Google OIDC token exchange (§8.2)"
  type        = string
  sensitive   = true
  default     = "placeholder-google-oidc-secret-dev"
}

variable "apple_oidc_client_secret" {
  description = "Client secret for Apple OIDC Sign-in (§8.2)"
  type        = string
  sensitive   = true
  default     = "placeholder-apple-oidc-secret-dev"
}

variable "cloudfront_key_pair_id" {
  description = "CloudFront public key ID or key group ID"
  type        = string
  default     = "placeholder-cf-key-id"
}

variable "cloudfront_signing_private_key_pem" {
  description = "CloudFront private key PEM for generating signed URLs (§8.2, §12.1)"
  type        = string
  sensitive   = true
  default     = "placeholder-cloudfront-private-key-dev"
}

variable "tags" {
  description = "Resource tags to be applied to all resources"
  type        = map(string)
  default     = {}
}
