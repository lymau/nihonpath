variable "name_prefix" {
  description = "Prefix for all resource names"
  type        = string
  default     = "nihonpath"
}

variable "environment" {
  description = "Deployment environment (e.g. dev, prod)"
  type        = string
  default     = "dev"
}

variable "vpc_id" {
  description = "VPC ID where database resources are provisioned"
  type        = string
}

variable "database_subnet_ids" {
  description = "List of private subnet IDs for database multi-AZ deployment"
  type        = list(string)
}

variable "client_security_group_ids" {
  description = "List of security group IDs permitted to connect to database and cache"
  type        = list(string)
  default     = []
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

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}
