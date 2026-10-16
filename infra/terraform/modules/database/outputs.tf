output "postgres_primary_endpoint" {
  description = "Connection endpoint of PostgreSQL primary instance"
  value       = aws_db_instance.primary.endpoint
}

output "postgres_primary_address" {
  description = "Address / hostname of PostgreSQL primary instance"
  value       = aws_db_instance.primary.address
}

output "postgres_replica_endpoint" {
  description = "Connection endpoint of PostgreSQL read replica instance"
  value       = aws_db_instance.replica.endpoint
}

output "postgres_replica_address" {
  description = "Address / hostname of PostgreSQL read replica instance"
  value       = aws_db_instance.replica.address
}

output "postgres_port" {
  description = "Port of PostgreSQL database service"
  value       = aws_db_instance.primary.port
}

output "postgres_db_name" {
  description = "Database name"
  value       = var.postgres_db_name
}

output "postgres_username" {
  description = "Master username for PostgreSQL"
  value       = var.postgres_username
}

output "postgres_password" {
  description = "Master password for PostgreSQL"
  value       = random_password.postgres_password.result
  sensitive   = true
}

output "statement_timeout_ms" {
  description = "Configured statement timeout in milliseconds (§11.3)"
  value       = var.statement_timeout_ms
}

output "pgbouncer_host" {
  description = "Internal NLB hostname for PgBouncer connection pooler"
  value       = aws_lb.pgbouncer.dns_name
}

output "pgbouncer_port" {
  description = "Port for PgBouncer connection pooler"
  value       = 6432
}

output "pgbouncer_pool_mode" {
  description = "Pool mode configured for PgBouncer (§11.2)"
  value       = var.pgbouncer_pool_mode
}

output "redis_primary_endpoint" {
  description = "Primary endpoint address of Redis ElastiCache cluster"
  value       = aws_elasticache_replication_group.redis.primary_endpoint_address
}

output "redis_reader_endpoint" {
  description = "Reader endpoint address of Redis ElastiCache cluster"
  value       = aws_elasticache_replication_group.redis.reader_endpoint_address
}

output "redis_port" {
  description = "Port of Redis service"
  value       = aws_elasticache_replication_group.redis.port
}

output "redis_auth_token" {
  description = "Auth token for Redis ElastiCache"
  value       = random_password.redis_auth_token.result
  sensitive   = true
}

output "database_kms_key_arn" {
  description = "ARN of the primary database and Redis KMS encryption key"
  value       = aws_kms_key.database.arn
}

output "singapore_backup_kms_key_arn" {
  description = "ARN of the Singapore disaster recovery KMS encryption key"
  value       = aws_kms_key.singapore_backup.arn
}

output "postgres_secret_arn" {
  description = "ARN of Secrets Manager secret containing PostgreSQL credentials"
  value       = aws_secretsmanager_secret.postgres.arn
}

output "redis_secret_arn" {
  description = "ARN of Secrets Manager secret containing Redis credentials"
  value       = aws_secretsmanager_secret.redis.arn
}

output "database_security_group_id" {
  description = "Security group ID of PostgreSQL instances"
  value       = aws_security_group.db.id
}

output "pgbouncer_security_group_id" {
  description = "Security group ID of PgBouncer service"
  value       = aws_security_group.pgbouncer.id
}

output "redis_security_group_id" {
  description = "Security group ID of Redis ElastiCache cluster"
  value       = aws_security_group.redis.id
}
