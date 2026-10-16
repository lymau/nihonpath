terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region                      = var.aws_region
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true

  default_tags {
    tags = merge(
      {
        Project     = "nihonpath"
        Environment = var.environment
        ManagedBy   = "terraform"
      },
      var.tags
    )
  }
}

provider "aws" {
  alias                       = "singapore"
  region                      = "ap-southeast-1"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true

  default_tags {
    tags = merge(
      {
        Project     = "nihonpath"
        Environment = var.environment
        ManagedBy   = "terraform"
      },
      var.tags
    )
  }
}

module "network" {
  source = "../../modules/network"

  name_prefix          = var.name_prefix
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  single_nat_gateway   = var.single_nat_gateway
  api_container_port   = var.api_container_port
  tags                 = var.tags
}

module "database" {
  source = "../../modules/database"

  providers = {
    aws           = aws
    aws.singapore = aws.singapore
  }

  name_prefix         = var.name_prefix
  environment         = var.environment
  vpc_id              = module.network.vpc_id
  database_subnet_ids = module.network.private_subnet_ids
  client_security_group_ids = [
    module.network.api_security_group_id,
    module.network.worker_security_group_id,
  ]
  postgres_engine_version        = var.postgres_engine_version
  postgres_instance_class        = var.postgres_instance_class
  postgres_allocated_storage     = var.postgres_allocated_storage
  postgres_max_allocated_storage = var.postgres_max_allocated_storage
  postgres_db_name               = var.postgres_db_name
  postgres_username              = var.postgres_username
  statement_timeout_ms           = var.statement_timeout_ms
  backup_retention_days          = var.backup_retention_days
  pgbouncer_image                = var.pgbouncer_image
  pgbouncer_pool_mode            = var.pgbouncer_pool_mode
  pgbouncer_default_pool_size    = var.pgbouncer_default_pool_size
  pgbouncer_max_client_conn      = var.pgbouncer_max_client_conn
  redis_engine_version           = var.redis_engine_version
  redis_node_type                = var.redis_node_type
  tags                           = var.tags
}

module "storage" {
  source = "../../modules/storage"

  name_prefix               = var.name_prefix
  environment               = var.environment
  content_packs_bucket_name = var.content_packs_bucket_name
  audio_bucket_name         = var.audio_bucket_name
  cors_allowed_origins      = var.cors_allowed_origins
  tags                      = var.tags
}

module "cdn" {
  source = "../../modules/cdn"

  name_prefix                               = var.name_prefix
  environment                               = var.environment
  content_packs_bucket_id                   = module.storage.content_packs_bucket_id
  content_packs_bucket_arn                  = module.storage.content_packs_bucket_arn
  content_packs_bucket_regional_domain_name = module.storage.content_packs_bucket_regional_domain_name
  audio_bucket_id                           = module.storage.audio_bucket_id
  audio_bucket_arn                          = module.storage.audio_bucket_arn
  audio_bucket_regional_domain_name         = module.storage.audio_bucket_regional_domain_name
  price_class                               = var.cloudfront_price_class
  tags                                      = var.tags
}

module "secrets" {
  source = "../../modules/secrets"

  name_prefix               = var.name_prefix
  environment               = var.environment
  jwt_key_id                = var.jwt_key_id
  jwt_algorithm             = var.jwt_algorithm
  jwt_public_key_pem        = var.jwt_public_key_pem
  jwt_private_key_pem       = var.jwt_private_key_pem
  revenuecat_webhook_secret = var.revenuecat_webhook_secret
  email_provider_api_key    = var.email_provider_api_key
  google_oidc_client_secret = var.google_oidc_client_secret
  apple_oidc_client_secret  = var.apple_oidc_client_secret
  cloudfront_key_pair_id    = module.cdn.cloudfront_key_group_id
  tags                      = var.tags
}

module "compute" {
  source = "../../modules/compute"

  name_prefix                = var.name_prefix
  environment                = var.environment
  aws_region                 = var.aws_region
  vpc_id                     = module.network.vpc_id
  public_subnet_ids          = module.network.public_subnet_ids
  private_subnet_ids         = module.network.private_subnet_ids
  alb_security_group_id      = module.network.alb_security_group_id
  api_security_group_id      = module.network.api_security_group_id
  worker_security_group_id   = module.network.worker_security_group_id
  api_image                  = var.api_image
  worker_image               = var.worker_image
  api_container_port         = var.api_container_port
  api_cpu                    = var.api_cpu
  api_memory                 = var.api_memory
  api_min_capacity           = var.api_min_capacity
  api_max_capacity           = var.api_max_capacity
  api_target_cpu_utilization = var.api_target_cpu_utilization
  worker_cpu                 = var.worker_cpu
  worker_memory              = var.worker_memory
  worker_desired_count       = var.worker_desired_count
  api_environment_variables = concat(
    [
      {
        name  = "DATABASE_URL"
        value = "postgresql://${module.database.postgres_username}:${module.database.postgres_password}@${module.database.pgbouncer_host}:${module.database.pgbouncer_port}/${module.database.postgres_db_name}"
      },
      {
        name  = "DB_REPLICA_URL"
        value = "postgresql://${module.database.postgres_username}:${module.database.postgres_password}@${module.database.postgres_replica_address}:${module.database.postgres_port}/${module.database.postgres_db_name}"
      },
      {
        name  = "REDIS_URL"
        value = "redis://:${module.database.redis_auth_token}@${module.database.redis_primary_endpoint}:${module.database.redis_port}"
      },
      {
        name  = "STORAGE_PACKS_BUCKET"
        value = module.storage.content_packs_bucket_id
      },
      {
        name  = "STORAGE_AUDIO_BUCKET"
        value = module.storage.audio_bucket_id
      },
      {
        name  = "CDN_DOMAIN"
        value = module.cdn.cloudfront_distribution_domain_name
      },
      {
        name  = "JWT_SECRET_ARN"
        value = module.secrets.jwt_signing_key_secret_arn
      },
      {
        name  = "THIRD_PARTY_SECRETS_ARN"
        value = module.secrets.third_party_api_keys_secret_arn
      }
    ],
    var.api_environment_variables
  )
  worker_environment_variables = concat(
    [
      {
        name  = "DATABASE_URL"
        value = "postgresql://${module.database.postgres_username}:${module.database.postgres_password}@${module.database.pgbouncer_host}:${module.database.pgbouncer_port}/${module.database.postgres_db_name}"
      },
      {
        name  = "REDIS_URL"
        value = "redis://:${module.database.redis_auth_token}@${module.database.redis_primary_endpoint}:${module.database.redis_port}"
      },
      {
        name  = "STORAGE_PACKS_BUCKET"
        value = module.storage.content_packs_bucket_id
      },
      {
        name  = "STORAGE_AUDIO_BUCKET"
        value = module.storage.audio_bucket_id
      }
    ],
    var.worker_environment_variables
  )
  tags = var.tags
}

# Attach IAM access policies to API task role (§8.2, §12.1)
resource "aws_iam_role_policy_attachment" "api_presigned_url_access" {
  role       = "${var.name_prefix}-${var.environment}-api-task-role"
  policy_arn = module.storage.presigned_url_policy_arn
  depends_on = [module.compute]
}

resource "aws_iam_role_policy_attachment" "api_secrets_read_access" {
  role       = "${var.name_prefix}-${var.environment}-api-task-role"
  policy_arn = module.secrets.secrets_read_policy_arn
  depends_on = [module.compute]
}
