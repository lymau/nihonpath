variable "aws_region" {
  description = "AWS region for deployment (§4.2 WAJIB ap-southeast-3 Jakarta)"
  type        = string
  default     = "ap-southeast-3"
}

variable "environment" {
  description = "Deployment environment name"
  type        = string
  default     = "dev"
}

variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
  default     = "nihonpath"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Jakarta availability zones"
  type        = list(string)
  default     = ["ap-southeast-3a", "ap-southeast-3b", "ap-southeast-3c"]
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
}

variable "single_nat_gateway" {
  description = "Whether to use a single NAT Gateway in dev for cost efficiency"
  type        = bool
  default     = true
}

variable "api_container_port" {
  description = "Port exposed by the API container"
  type        = number
  default     = 3000
}

variable "api_image" {
  description = "API Docker container image"
  type        = string
  default     = "public.ecr.aws/ecs-sample-image/amazon-ecs-sample:latest"
}

variable "worker_image" {
  description = "Worker Docker container image"
  type        = string
  default     = "public.ecr.aws/ecs-sample-image/amazon-ecs-sample:latest"
}

variable "api_cpu" {
  description = "CPU allocated for API task"
  type        = number
  default     = 256
}

variable "api_memory" {
  description = "Memory allocated for API task (MiB)"
  type        = number
  default     = 512
}

variable "api_min_capacity" {
  description = "Minimum API container count (§11.2)"
  type        = number
  default     = 2
}

variable "api_max_capacity" {
  description = "Maximum API container count"
  type        = number
  default     = 5
}

variable "api_target_cpu_utilization" {
  description = "Autoscale target CPU utilization percentage (§11.2)"
  type        = number
  default     = 60.0
}

variable "worker_cpu" {
  description = "CPU allocated for BullMQ worker task"
  type        = number
  default     = 256
}

variable "worker_memory" {
  description = "Memory allocated for BullMQ worker task (MiB)"
  type        = number
  default     = 512
}

variable "worker_desired_count" {
  description = "Desired BullMQ worker count"
  type        = number
  default     = 1
}

variable "api_environment_variables" {
  description = "Environment variables for API container"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "worker_environment_variables" {
  description = "Environment variables for BullMQ worker container"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "postgres_engine_version" {
  description = "PostgreSQL major.minor version (>= 16)"
  type        = string
  default     = "16.4"
}

variable "postgres_instance_class" {
  description = "RDS instance class for primary and read replica"
  type        = string
  default     = "db.t4g.micro"
}

variable "postgres_allocated_storage" {
  description = "Initial allocated storage in GB"
  type        = number
  default     = 20
}

variable "postgres_max_allocated_storage" {
  description = "Maximum storage limit in GB for autoscaling"
  type        = number
  default     = 100
}

variable "postgres_db_name" {
  description = "Name of the default PostgreSQL database"
  type        = string
  default     = "nihonpath_dev"
}

variable "postgres_username" {
  description = "Master username for PostgreSQL"
  type        = string
  default     = "nihonpath_admin"
}

variable "statement_timeout_ms" {
  description = "Database statement timeout in milliseconds (§11.3, 3 seconds = 3000 ms)"
  type        = number
  default     = 3000
}

variable "backup_retention_days" {
  description = "Continuous PITR and backup retention in days (§11.4, default 14)"
  type        = number
  default     = 14
}

variable "pgbouncer_image" {
  description = "Container image for PgBouncer"
  type        = string
  default     = "edoburu/pgbouncer:1.23.1"
}

variable "pgbouncer_pool_mode" {
  description = "PgBouncer pool mode (§11.2, must be transaction)"
  type        = string
  default     = "transaction"
}

variable "pgbouncer_default_pool_size" {
  description = "Default pool size for PgBouncer"
  type        = number
  default     = 20
}

variable "pgbouncer_max_client_conn" {
  description = "Maximum client connections for PgBouncer"
  type        = number
  default     = 100
}

variable "redis_engine_version" {
  description = "Redis engine version (>= 7.0)"
  type        = string
  default     = "7.1"
}

variable "redis_node_type" {
  description = "ElastiCache node type for Redis replication group"
  type        = string
  default     = "cache.t4g.micro"
}

variable "content_packs_bucket_name" {
  description = "Custom name for content packs S3 bucket (leave empty for default)"
  type        = string
  default     = ""
}

variable "audio_bucket_name" {
  description = "Custom name for pre-rendered audio S3 bucket (leave empty for default)"
  type        = string
  default     = ""
}

variable "cors_allowed_origins" {
  description = "Allowed origins for storage CORS"
  type        = list(string)
  default     = ["*"]
}

variable "cloudfront_price_class" {
  description = "CloudFront distribution price class"
  type        = string
  default     = "PriceClass_100"
}

variable "jwt_key_id" {
  description = "JWT key identifier (kid) supporting rotation (§8.3)"
  type        = string
  default     = "nihonpath-dev-jwt-v1"
}

variable "jwt_algorithm" {
  description = "JWT signing algorithm (ES256 or EdDSA §8.3)"
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
  description = "Public key PEM for JWT verification (JWKS §8.3)"
  type        = string
  default     = "placeholder-jwt-public-key-for-dev"
}

variable "revenuecat_webhook_secret" {
  description = "RevenueCat webhook authorization secret (§13)"
  type        = string
  sensitive   = true
  default     = "placeholder-revenuecat-webhook-secret-dev"
}

variable "email_provider_api_key" {
  description = "Transactional email provider API key (§8.3)"
  type        = string
  sensitive   = true
  default     = "placeholder-email-provider-key-dev"
}

variable "google_oidc_client_secret" {
  description = "Google OIDC client secret (§8.2)"
  type        = string
  sensitive   = true
  default     = "placeholder-google-oidc-secret-dev"
}

variable "apple_oidc_client_secret" {
  description = "Apple OIDC client secret (§8.2)"
  type        = string
  sensitive   = true
  default     = "placeholder-apple-oidc-secret-dev"
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}

