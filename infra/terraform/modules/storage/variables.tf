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

variable "content_packs_bucket_name" {
  description = "Custom name for the content packs S3 bucket. If empty, a default name is generated."
  type        = string
  default     = ""
}

variable "audio_bucket_name" {
  description = "Custom name for the pre-rendered audio S3 bucket. If empty, a default name is generated."
  type        = string
  default     = ""
}

variable "cors_allowed_origins" {
  description = "Allowed origins for S3 bucket CORS configuration"
  type        = list(string)
  default     = ["*"]
}

variable "tags" {
  description = "Resource tags to be applied to all resources"
  type        = map(string)
  default     = {}
}
