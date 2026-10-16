terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "~> 5.0"
      configuration_aliases = [aws.singapore]
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

# --- KMS Keys ---

resource "aws_kms_key" "database" {
  description             = "KMS key for database and cache encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = merge(var.tags, {
    Name        = "${var.name_prefix}-${var.environment}-db-kms"
    Environment = var.environment
  })
}

resource "aws_kms_alias" "database" {
  name          = "alias/${var.name_prefix}-${var.environment}-database"
  target_key_id = aws_kms_key.database.key_id
}

resource "aws_kms_key" "singapore_backup" {
  provider                = aws.singapore
  description             = "KMS key for cross-region backup replication in Singapore"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = merge(var.tags, {
    Name        = "${var.name_prefix}-${var.environment}-backup-singapore-kms"
    Environment = var.environment
  })
}

resource "aws_kms_alias" "singapore_backup" {
  provider      = aws.singapore
  name          = "alias/${var.name_prefix}-${var.environment}-backup-singapore"
  target_key_id = aws_kms_key.singapore_backup.key_id
}

# --- Passwords & Subnet Groups ---

resource "random_password" "postgres_password" {
  length  = 24
  special = false
}

resource "random_password" "redis_auth_token" {
  length  = 32
  special = false
}

resource "aws_db_subnet_group" "database" {
  name        = "${var.name_prefix}-${var.environment}-db-subnets"
  description = "Multi-AZ subnets for PostgreSQL"
  subnet_ids  = var.database_subnet_ids

  tags = merge(var.tags, {
    Name        = "${var.name_prefix}-${var.environment}-db-subnets"
    Environment = var.environment
  })
}

resource "aws_elasticache_subnet_group" "redis" {
  name        = "${var.name_prefix}-${var.environment}-redis-subnets"
  description = "Multi-AZ subnets for Redis ElastiCache"
  subnet_ids  = var.database_subnet_ids

  tags = merge(var.tags, {
    Name        = "${var.name_prefix}-${var.environment}-redis-subnets"
    Environment = var.environment
  })
}

# --- Security Groups ---

resource "aws_security_group" "db" {
  name        = "${var.name_prefix}-${var.environment}-db-sg"
  description = "Security group for PostgreSQL primary and read replica"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow PostgreSQL access from clients and PgBouncer"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = concat(var.client_security_group_ids, [aws_security_group.pgbouncer.id])
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name        = "${var.name_prefix}-${var.environment}-db-sg"
    Environment = var.environment
  })
}

resource "aws_security_group" "pgbouncer" {
  name        = "${var.name_prefix}-${var.environment}-pgbouncer-sg"
  description = "Security group for PgBouncer connection pooler"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow traffic from client services to PgBouncer port"
    from_port       = 6432
    to_port         = 6432
    protocol        = "tcp"
    security_groups = var.client_security_group_ids
  }

  egress {
    description = "Allow outbound to database and VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name        = "${var.name_prefix}-${var.environment}-pgbouncer-sg"
    Environment = var.environment
  })
}

resource "aws_security_group" "redis" {
  name        = "${var.name_prefix}-${var.environment}-redis-sg"
  description = "Security group for Redis ElastiCache cluster"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow Redis access from client services"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = var.client_security_group_ids
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name        = "${var.name_prefix}-${var.environment}-redis-sg"
    Environment = var.environment
  })
}

# --- PostgreSQL Parameter Group & Monitoring Role ---

resource "aws_db_parameter_group" "postgres" {
  name        = "${var.name_prefix}-${var.environment}-pg16-params"
  family      = "postgres16"
  description = "PostgreSQL 16 parameter group with statement timeout"

  parameter {
    name  = "statement_timeout"
    value = tostring(var.statement_timeout_ms)
  }

  parameter {
    name  = "log_connections"
    value = "1"
  }

  parameter {
    name  = "log_disconnections"
    value = "1"
  }

  tags = merge(var.tags, {
    Name        = "${var.name_prefix}-${var.environment}-pg16-params"
    Environment = var.environment
  })
}

resource "aws_iam_role" "rds_monitoring" {
  name = "${var.name_prefix}-${var.environment}-rds-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "rds.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name        = "${var.name_prefix}-${var.environment}-rds-monitoring-role"
    Environment = var.environment
  })
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  role       = aws_iam_role.rds_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# --- PostgreSQL Primary (Multi-AZ) & Read Replica ---

resource "aws_db_instance" "primary" {
  identifier                      = "${var.name_prefix}-${var.environment}-postgres-primary"
  engine                          = "postgres"
  engine_version                  = var.postgres_engine_version
  instance_class                  = var.postgres_instance_class
  allocated_storage               = var.postgres_allocated_storage
  max_allocated_storage           = var.postgres_max_allocated_storage
  storage_type                    = "gp3"
  storage_encrypted               = true
  kms_key_id                      = aws_kms_key.database.arn
  db_name                         = var.postgres_db_name
  username                        = var.postgres_username
  password                        = random_password.postgres_password.result
  multi_az                        = true
  db_subnet_group_name            = aws_db_subnet_group.database.name
  vpc_security_group_ids          = [aws_security_group.db.id]
  parameter_group_name            = aws_db_parameter_group.postgres.name
  backup_retention_period         = var.backup_retention_days
  backup_window                   = "02:00-03:00"
  maintenance_window              = "Sun:04:00-Sun:05:00"
  auto_minor_version_upgrade      = true
  skip_final_snapshot             = var.environment == "dev"
  deletion_protection             = var.environment != "dev"
  monitoring_interval             = 60
  monitoring_role_arn             = aws_iam_role.rds_monitoring.arn
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  tags = merge(var.tags, {
    Name        = "${var.name_prefix}-${var.environment}-postgres-primary"
    Environment = var.environment
    Role        = "primary"
  })
}

resource "aws_db_instance" "replica" {
  identifier                 = "${var.name_prefix}-${var.environment}-postgres-replica"
  replicate_source_db        = aws_db_instance.primary.identifier
  instance_class             = var.postgres_instance_class
  storage_type               = "gp3"
  storage_encrypted          = true
  kms_key_id                 = aws_kms_key.database.arn
  vpc_security_group_ids     = [aws_security_group.db.id]
  parameter_group_name       = aws_db_parameter_group.postgres.name
  auto_minor_version_upgrade = true
  skip_final_snapshot        = true
  monitoring_interval        = 60
  monitoring_role_arn        = aws_iam_role.rds_monitoring.arn

  tags = merge(var.tags, {
    Name        = "${var.name_prefix}-${var.environment}-postgres-replica"
    Environment = var.environment
    Role        = "replica"
  })
}

# --- Cross-Region Automated Backup Replication (Singapore §11.4) ---

resource "aws_db_instance_automated_backups_replication" "singapore" {
  provider               = aws.singapore
  source_db_instance_arn = aws_db_instance.primary.arn
  retention_period       = var.backup_retention_days
  kms_key_id             = aws_kms_key.singapore_backup.arn
}

# --- PgBouncer Connection Pooler (Transaction Mode §11.2) ---

resource "aws_ecs_cluster" "pgbouncer" {
  name = "${var.name_prefix}-${var.environment}-pgbouncer-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = merge(var.tags, {
    Name        = "${var.name_prefix}-${var.environment}-pgbouncer-cluster"
    Environment = var.environment
  })
}

resource "aws_cloudwatch_log_group" "pgbouncer" {
  name              = "/ecs/${var.name_prefix}-${var.environment}-pgbouncer"
  retention_in_days = 7

  tags = merge(var.tags, {
    Name        = "${var.name_prefix}-${var.environment}-pgbouncer-logs"
    Environment = var.environment
  })
}

resource "aws_iam_role" "pgbouncer_execution" {
  name = "${var.name_prefix}-${var.environment}-pgbouncer-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name        = "${var.name_prefix}-${var.environment}-pgbouncer-exec-role"
    Environment = var.environment
  })
}

resource "aws_iam_role_policy_attachment" "pgbouncer_execution" {
  role       = aws_iam_role.pgbouncer_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "pgbouncer" {
  family                   = "${var.name_prefix}-${var.environment}-pgbouncer"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.pgbouncer_execution.arn

  container_definitions = jsonencode([
    {
      name      = "pgbouncer"
      image     = var.pgbouncer_image
      essential = true
      portMappings = [
        {
          containerPort = 6432
          hostPort      = 6432
          protocol      = "tcp"
        }
      ]
      environment = [
        { name = "DB_HOST", value = aws_db_instance.primary.address },
        { name = "DB_PORT", value = "5432" },
        { name = "DB_USER", value = var.postgres_username },
        { name = "DB_PASSWORD", value = random_password.postgres_password.result },
        { name = "POOL_MODE", value = var.pgbouncer_pool_mode },
        { name = "DEFAULT_POOL_SIZE", value = tostring(var.pgbouncer_default_pool_size) },
        { name = "MAX_CLIENT_CONN", value = tostring(var.pgbouncer_max_client_conn) },
        { name = "SERVER_RESET_QUERY", value = "DISCARD ALL" },
        { name = "LISTEN_PORT", value = "6432" },
        { name = "AUTH_TYPE", value = "scram-sha-256" }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.pgbouncer.name
          "awslogs-region"        = "ap-southeast-3"
          "awslogs-stream-prefix" = "pgbouncer"
        }
      }
    }
  ])

  tags = merge(var.tags, {
    Name        = "${var.name_prefix}-${var.environment}-pgbouncer-task"
    Environment = var.environment
  })
}

resource "aws_lb" "pgbouncer" {
  name               = "${var.name_prefix}-${var.environment}-pgb-nlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = var.database_subnet_ids

  tags = merge(var.tags, {
    Name        = "${var.name_prefix}-${var.environment}-pgb-nlb"
    Environment = var.environment
  })
}

resource "aws_lb_target_group" "pgbouncer" {
  name        = "${var.name_prefix}-${var.environment}-pgb-tg"
  port        = 6432
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled  = true
    protocol = "TCP"
    port     = "6432"
  }

  tags = merge(var.tags, {
    Name        = "${var.name_prefix}-${var.environment}-pgb-tg"
    Environment = var.environment
  })
}

resource "aws_lb_listener" "pgbouncer" {
  load_balancer_arn = aws_lb.pgbouncer.arn
  port              = 6432
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.pgbouncer.arn
  }
}

resource "aws_ecs_service" "pgbouncer" {
  name            = "${var.name_prefix}-${var.environment}-pgbouncer"
  cluster         = aws_ecs_cluster.pgbouncer.id
  task_definition = aws_ecs_task_definition.pgbouncer.arn
  launch_type     = "FARGATE"
  desired_count   = 2

  network_configuration {
    subnets         = var.database_subnet_ids
    security_groups = [aws_security_group.pgbouncer.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.pgbouncer.arn
    container_name   = "pgbouncer"
    container_port   = 6432
  }

  tags = merge(var.tags, {
    Name        = "${var.name_prefix}-${var.environment}-pgbouncer-service"
    Environment = var.environment
  })

  depends_on = [aws_lb_listener.pgbouncer]
}

# --- Redis ElastiCache HA (Multi-AZ §4.2, §11.2) ---

resource "aws_elasticache_parameter_group" "redis" {
  name        = "${var.name_prefix}-${var.environment}-redis-params"
  family      = "redis7"
  description = "Redis 7 parameter group with BullMQ durability"

  parameter {
    name  = "maxmemory-policy"
    value = "noeviction"
  }

  tags = merge(var.tags, {
    Name        = "${var.name_prefix}-${var.environment}-redis-params"
    Environment = var.environment
  })
}

resource "aws_elasticache_replication_group" "redis" {
  replication_group_id       = "${var.name_prefix}-${var.environment}-redis"
  description                = "Redis HA cluster for cache, rate limiting, and BullMQ"
  engine                     = "redis"
  engine_version             = var.redis_engine_version
  node_type                  = var.redis_node_type
  num_cache_clusters         = 2
  multi_az_enabled           = true
  automatic_failover_enabled = true
  subnet_group_name          = aws_elasticache_subnet_group.redis.name
  security_group_ids         = [aws_security_group.redis.id]
  parameter_group_name       = aws_elasticache_parameter_group.redis.name
  port                       = 6379
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  auth_token                 = random_password.redis_auth_token.result
  kms_key_id                 = aws_kms_key.database.arn
  snapshot_retention_limit   = 7
  snapshot_window            = "03:00-04:00"

  tags = merge(var.tags, {
    Name        = "${var.name_prefix}-${var.environment}-redis"
    Environment = var.environment
  })
}

# --- Secret Manager Integration (§12.1) ---

resource "aws_secretsmanager_secret" "postgres" {
  name        = "${var.name_prefix}/${var.environment}/database/postgres"
  description = "Credentials for PostgreSQL and PgBouncer"
  kms_key_id  = aws_kms_key.database.arn

  tags = merge(var.tags, {
    Name        = "${var.name_prefix}/${var.environment}/database/postgres"
    Environment = var.environment
  })
}

resource "aws_secretsmanager_secret_version" "postgres" {
  secret_id = aws_secretsmanager_secret.postgres.id
  secret_string = jsonencode({
    engine         = "postgres"
    host           = aws_db_instance.primary.address
    port           = 5432
    db_name        = var.postgres_db_name
    username       = var.postgres_username
    password       = random_password.postgres_password.result
    replica_host   = aws_db_instance.replica.address
    pgbouncer_host = aws_lb.pgbouncer.dns_name
    pgbouncer_port = 6432
  })
}

resource "aws_secretsmanager_secret" "redis" {
  name        = "${var.name_prefix}/${var.environment}/database/redis"
  description = "Credentials and connection details for Redis ElastiCache"
  kms_key_id  = aws_kms_key.database.arn

  tags = merge(var.tags, {
    Name        = "${var.name_prefix}/${var.environment}/database/redis"
    Environment = var.environment
  })
}

resource "aws_secretsmanager_secret_version" "redis" {
  secret_id = aws_secretsmanager_secret.redis.id
  secret_string = jsonencode({
    engine           = "redis"
    primary_endpoint = aws_elasticache_replication_group.redis.primary_endpoint_address
    reader_endpoint  = aws_elasticache_replication_group.redis.reader_endpoint_address
    port             = 6379
    auth_token       = random_password.redis_auth_token.result
  })
}

# --- Observability Alarms (CloudWatch §10, §11) ---

resource "aws_cloudwatch_metric_alarm" "postgres_cpu" {
  alarm_name          = "${var.name_prefix}-${var.environment}-postgres-cpu-utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 3
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "RDS primary CPU utilization exceeds 80% for 15 minutes (§11)"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.primary.id
  }

  tags = merge(var.tags, {
    Name        = "${var.name_prefix}-${var.environment}-postgres-cpu-alarm"
    Environment = var.environment
  })
}

resource "aws_cloudwatch_metric_alarm" "postgres_memory" {
  alarm_name          = "${var.name_prefix}-${var.environment}-postgres-freeable-memory"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "FreeableMemory"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 268435456 # 256 MB in bytes
  alarm_description   = "RDS primary freeable memory is low"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.primary.id
  }

  tags = merge(var.tags, {
    Name        = "${var.name_prefix}-${var.environment}-postgres-mem-alarm"
    Environment = var.environment
  })
}

resource "aws_cloudwatch_metric_alarm" "postgres_disk" {
  alarm_name          = "${var.name_prefix}-${var.environment}-postgres-free-disk-space"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 5368709120 # 5 GB in bytes
  alarm_description   = "RDS primary free disk storage is below 5 GB"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.primary.id
  }

  tags = merge(var.tags, {
    Name        = "${var.name_prefix}-${var.environment}-postgres-disk-alarm"
    Environment = var.environment
  })
}

resource "aws_cloudwatch_metric_alarm" "postgres_connections" {
  alarm_name          = "${var.name_prefix}-${var.environment}-postgres-connections"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "RDS primary active connections exceed 80 (§11)"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.primary.id
  }

  tags = merge(var.tags, {
    Name        = "${var.name_prefix}-${var.environment}-postgres-conn-alarm"
    Environment = var.environment
  })
}
