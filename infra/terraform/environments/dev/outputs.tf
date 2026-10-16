output "vpc_id" {
  description = "VPC ID of the dev environment"
  value       = module.network.vpc_id
}

output "public_subnets" {
  description = "Public subnet IDs in dev environment"
  value       = module.network.public_subnet_ids
}

output "private_subnets" {
  description = "Private subnet IDs in dev environment"
  value       = module.network.private_subnet_ids
}

output "alb_dns_name" {
  description = "Public DNS hostname of the API Application Load Balancer"
  value       = module.compute.alb_dns_name
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.compute.ecs_cluster_name
}

output "api_service_name" {
  description = "Name of the API ECS service"
  value       = module.compute.api_service_name
}

output "worker_service_name" {
  description = "Name of the Worker ECS service"
  value       = module.compute.worker_service_name
}

output "database_primary_endpoint" {
  description = "Endpoint of PostgreSQL primary instance"
  value       = module.database.postgres_primary_endpoint
}

output "database_primary_address" {
  description = "Hostname of PostgreSQL primary instance"
  value       = module.database.postgres_primary_address
}

output "database_replica_endpoint" {
  description = "Endpoint of PostgreSQL read replica instance"
  value       = module.database.postgres_replica_endpoint
}

output "database_replica_address" {
  description = "Hostname of PostgreSQL read replica instance"
  value       = module.database.postgres_replica_address
}

output "pgbouncer_host" {
  description = "Internal NLB hostname for PgBouncer connection pooler"
  value       = module.database.pgbouncer_host
}

output "pgbouncer_port" {
  description = "Port for PgBouncer connection pooler"
  value       = module.database.pgbouncer_port
}

output "redis_primary_endpoint" {
  description = "Primary endpoint of Redis ElastiCache cluster"
  value       = module.database.redis_primary_endpoint
}

output "redis_reader_endpoint" {
  description = "Reader endpoint of Redis ElastiCache cluster"
  value       = module.database.redis_reader_endpoint
}

output "redis_port" {
  description = "Port of Redis ElastiCache service"
  value       = module.database.redis_port
}

output "database_kms_key_arn" {
  description = "ARN of KMS key used for database & cache encryption"
  value       = module.database.database_kms_key_arn
}

output "singapore_backup_kms_key_arn" {
  description = "ARN of KMS key used for replicated backups in Singapore"
  value       = module.database.singapore_backup_kms_key_arn
}

output "postgres_secret_arn" {
  description = "ARN of Secret Manager secret for PostgreSQL"
  value       = module.database.postgres_secret_arn
}

output "redis_secret_arn" {
  description = "ARN of Secret Manager secret for Redis"
  value       = module.database.redis_secret_arn
}

output "content_packs_bucket_id" {
  description = "Name/ID of content packs S3 bucket"
  value       = module.storage.content_packs_bucket_id
}

output "content_packs_bucket_arn" {
  description = "ARN of content packs S3 bucket"
  value       = module.storage.content_packs_bucket_arn
}

output "audio_bucket_id" {
  description = "Name/ID of audio S3 bucket"
  value       = module.storage.audio_bucket_id
}

output "audio_bucket_arn" {
  description = "ARN of audio S3 bucket"
  value       = module.storage.audio_bucket_arn
}

output "cloudfront_distribution_id" {
  description = "ID of CloudFront distribution"
  value       = module.cdn.cloudfront_distribution_id
}

output "cloudfront_distribution_domain_name" {
  description = "Domain name of CloudFront distribution"
  value       = module.cdn.cloudfront_distribution_domain_name
}

output "cloudfront_key_group_id" {
  description = "ID of CloudFront key group for signed URLs"
  value       = module.cdn.cloudfront_key_group_id
}

output "cdn_logs_bucket_id" {
  description = "S3 bucket name for CDN access logs"
  value       = module.cdn.logs_bucket_id
}

output "secrets_kms_key_arn" {
  description = "ARN of KMS CMK for secret encryption"
  value       = module.secrets.kms_key_arn
}

output "jwt_signing_key_secret_arn" {
  description = "ARN of Secret Manager secret for JWT signing keys"
  value       = module.secrets.jwt_signing_key_secret_arn
}

output "third_party_api_keys_secret_arn" {
  description = "ARN of Secret Manager secret for third-party API keys"
  value       = module.secrets.third_party_api_keys_secret_arn
}

