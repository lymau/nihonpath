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

variable "content_packs_bucket_id" {
  description = "Name/ID of the content packs S3 bucket"
  type        = string
}

variable "content_packs_bucket_arn" {
  description = "ARN of the content packs S3 bucket"
  type        = string
}

variable "content_packs_bucket_regional_domain_name" {
  description = "Regional domain name of the content packs S3 bucket"
  type        = string
}

variable "audio_bucket_id" {
  description = "Name/ID of the audio S3 bucket"
  type        = string
}

variable "audio_bucket_arn" {
  description = "ARN of the audio S3 bucket"
  type        = string
}

variable "audio_bucket_regional_domain_name" {
  description = "Regional domain name of the audio S3 bucket"
  type        = string
}

variable "cloudfront_signing_public_key_pem" {
  description = "Public key PEM (RSA 2048) for signing CloudFront premium content URLs"
  type        = string
  default     = <<-EOT
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAk5bO6l7cHWBiWEeRQAcU
kKLdozzIByscLcYuPvqVN0imjiae21kr/usskZpCnj094FT1OwzVKFiWmx76dRaL
m3Kak2mY5eqXeXOvSbHlQRVl8vLIJE5xKKwDa3UOBacx0OBICY9IQKMByHrr32mz
n5cik6kvXV9OSuhcU4GZZ9rk30lnS9fyQ10t75VOQDhW6SLMoAVXtDYKM1TyRqgv
3NrkmtXHEY02BF65mM3611xky0+fR7k093cEqQ0a9s2eOhwdjMCDxA3wOkV+QoJu
SjmFlSDttBLdlix4QSVdsCm4GmufliiY3JiNS9CPf0QdgiS8C4oOe/6RxF/1IfV2
aQIDAQAB
-----END PUBLIC KEY-----
EOT
}

variable "price_class" {
  description = "CloudFront price class"
  type        = string
  default     = "PriceClass_100"
}

variable "alarm_evaluation_periods" {
  description = "Evaluation periods for CloudWatch alarms"
  type        = number
  default     = 2
}

variable "alarm_period_seconds" {
  description = "Period in seconds for CloudWatch alarms"
  type        = number
  default     = 300
}

variable "cdn_5xx_error_threshold_percent" {
  description = "CloudFront 5xx error rate threshold percentage"
  type        = number
  default     = 5.0
}

variable "cdn_4xx_error_threshold_percent" {
  description = "CloudFront 4xx error rate threshold percentage"
  type        = number
  default     = 10.0
}

variable "tags" {
  description = "Resource tags to be applied to all resources"
  type        = map(string)
  default     = {}
}
