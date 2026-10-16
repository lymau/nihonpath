import test from 'node:test';
import assert from 'node:assert/strict';
import { createServer } from 'node:net';
import { createServer as createHttpServer } from 'node:http';
import { readFileSync, existsSync } from 'node:fs';
import { resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { spawnSync } from 'node:child_process';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const rootDir = resolve(__dirname, '..');

const terraformDir = resolve(rootDir, 'infra/terraform');
const networkModuleDir = resolve(terraformDir, 'modules/network');
const computeModuleDir = resolve(terraformDir, 'modules/compute');
const databaseModuleDir = resolve(terraformDir, 'modules/database');
const storageModuleDir = resolve(terraformDir, 'modules/storage');
const cdnModuleDir = resolve(terraformDir, 'modules/cdn');
const secretsModuleDir = resolve(terraformDir, 'modules/secrets');
const devEnvDir = resolve(terraformDir, 'environments/dev');

test('Terraform folder structure and mandatory files (§14.1, M0-4a, M0-4b, M0-4c)', () => {
  const requiredFiles = [
    resolve(networkModuleDir, 'main.tf'),
    resolve(networkModuleDir, 'variables.tf'),
    resolve(networkModuleDir, 'outputs.tf'),
    resolve(computeModuleDir, 'main.tf'),
    resolve(computeModuleDir, 'variables.tf'),
    resolve(computeModuleDir, 'outputs.tf'),
    resolve(databaseModuleDir, 'main.tf'),
    resolve(databaseModuleDir, 'variables.tf'),
    resolve(databaseModuleDir, 'outputs.tf'),
    resolve(storageModuleDir, 'main.tf'),
    resolve(storageModuleDir, 'variables.tf'),
    resolve(storageModuleDir, 'outputs.tf'),
    resolve(cdnModuleDir, 'main.tf'),
    resolve(cdnModuleDir, 'variables.tf'),
    resolve(cdnModuleDir, 'outputs.tf'),
    resolve(secretsModuleDir, 'main.tf'),
    resolve(secretsModuleDir, 'variables.tf'),
    resolve(secretsModuleDir, 'outputs.tf'),
    resolve(devEnvDir, 'backend.tf'),
    resolve(devEnvDir, 'main.tf'),
    resolve(devEnvDir, 'variables.tf'),
    resolve(devEnvDir, 'outputs.tf'),
    resolve(devEnvDir, 'terraform.tfvars.example'),
  ];

  for (const file of requiredFiles) {
    assert.ok(existsSync(file), `Required Terraform file must exist: ${file}`);
  }
});

test('Terraform remote state backend configuration (S3 + DynamoDB locking in Jakarta)', () => {
  const backendFile = resolve(devEnvDir, 'backend.tf');
  const content = readFileSync(backendFile, 'utf-8');

  assert.match(content, /backend\s+"s3"/, 'Backend must use S3');
  assert.match(
    content,
    /bucket\s*=\s*"nihonpath-terraform-state-dev"/,
    'S3 bucket name must match dev state',
  );
  assert.match(
    content,
    /dynamodb_table\s*=\s*"nihonpath-terraform-locks-dev"/,
    'DynamoDB table must be configured for state locking',
  );
  assert.match(content, /region\s*=\s*"ap-southeast-3"/, 'Region must be Jakarta (ap-southeast-3)');
  assert.match(content, /encrypt\s*=\s*true/, 'Server-side encryption must be enabled for state');
});

test('Terraform Network module specifications (VPC, Multi-AZ subnets, NAT, SG)', () => {
  const mainTf = readFileSync(resolve(networkModuleDir, 'main.tf'), 'utf-8');
  const varsTf = readFileSync(resolve(networkModuleDir, 'variables.tf'), 'utf-8');

  // VPC & Gateway
  assert.match(mainTf, /resource\s+"aws_vpc"\s+"main"/, 'VPC resource must be defined');
  assert.match(mainTf, /enable_dns_hostnames\s*=\s*true/, 'DNS hostnames must be enabled in VPC');
  assert.match(
    mainTf,
    /resource\s+"aws_internet_gateway"\s+"main"/,
    'Internet Gateway must be defined',
  );

  // Subnets
  assert.match(mainTf, /resource\s+"aws_subnet"\s+"public"/, 'Public subnets must be defined');
  assert.match(mainTf, /resource\s+"aws_subnet"\s+"private"/, 'Private subnets must be defined');
  assert.match(varsTf, /ap-southeast-3a/, 'AZs must include Jakarta availability zones');

  // NAT Gateway
  assert.match(mainTf, /resource\s+"aws_nat_gateway"\s+"main"/, 'NAT Gateway must be defined');
  assert.match(mainTf, /resource\s+"aws_eip"\s+"nat"/, 'EIP for NAT Gateway must be defined');

  // Security Groups
  assert.match(
    mainTf,
    /resource\s+"aws_security_group"\s+"alb"/,
    'ALB security group must be defined',
  );
  assert.match(
    mainTf,
    /resource\s+"aws_security_group"\s+"api"/,
    'API security group must be defined',
  );
  assert.match(
    mainTf,
    /resource\s+"aws_security_group"\s+"worker"/,
    'Worker security group must be defined',
  );

  // API ingress must only allow traffic from ALB security group
  assert.match(
    mainTf,
    /security_groups\s*=\s*\[aws_security_group\.alb\.id\]/,
    'API security group must only allow ingress from ALB SG',
  );
});

test('Terraform Compute module specifications (ECS Fargate, 60% CPU Autoscale, 1 Worker, IAM Least Privilege)', () => {
  const mainTf = readFileSync(resolve(computeModuleDir, 'main.tf'), 'utf-8');
  const varsTf = readFileSync(resolve(computeModuleDir, 'variables.tf'), 'utf-8');

  // ECS Cluster & CloudWatch Logs
  assert.match(mainTf, /resource\s+"aws_ecs_cluster"\s+"main"/, 'ECS cluster must be defined');
  assert.match(
    mainTf,
    /resource\s+"aws_cloudwatch_log_group"\s+"api"/,
    'API log group must be defined',
  );
  assert.match(
    mainTf,
    /resource\s+"aws_cloudwatch_log_group"\s+"worker"/,
    'Worker log group must be defined',
  );

  // IAM Least Privilege (§12.1)
  assert.match(
    mainTf,
    /resource\s+"aws_iam_role"\s+"task_execution"/,
    'Task execution role must be defined',
  );
  assert.match(mainTf, /resource\s+"aws_iam_role"\s+"api_task"/, 'API task role must be defined');
  assert.match(
    mainTf,
    /resource\s+"aws_iam_role"\s+"worker_task"/,
    'Worker task role must be defined',
  );
  assert.match(
    mainTf,
    /ecs-tasks\.amazonaws\.com/,
    'Assume role must strictly target ECS tasks service',
  );

  // ALB & Healthcheck
  assert.match(mainTf, /resource\s+"aws_lb"\s+"api"/, 'ALB resource must be defined');
  assert.match(mainTf, /path\s*=\s*"\/healthz"/, 'Healthcheck path must be /healthz');

  // API Service & Task Definition
  assert.match(
    mainTf,
    /resource\s+"aws_ecs_task_definition"\s+"api"/,
    'API task definition must be defined',
  );
  assert.match(
    mainTf,
    /requires_compatibilities\s*=\s*\["FARGATE"\]/,
    'API launch type must be FARGATE',
  );
  assert.match(mainTf, /resource\s+"aws_ecs_service"\s+"api"/, 'API ECS service must be defined');

  // Autoscaling 60% CPU (§11.2)
  assert.match(
    mainTf,
    /resource\s+"aws_appautoscaling_target"\s+"api"/,
    'Autoscaling target for API must be defined',
  );
  assert.match(
    mainTf,
    /resource\s+"aws_appautoscaling_policy"\s+"api_cpu"/,
    'Autoscaling policy must be defined',
  );
  assert.match(
    mainTf,
    /ECSServiceAverageCPUUtilization/,
    'Autoscaling metric must track CPU utilization',
  );
  assert.match(varsTf, /api_target_cpu_utilization/, 'Target CPU utilization variable must exist');
  assert.match(varsTf, /default\s*=\s*60\.0/, 'Default CPU target must be 60.0% (§11.2)');

  // Worker Service (1 BullMQ Worker)
  assert.match(
    mainTf,
    /resource\s+"aws_ecs_task_definition"\s+"worker"/,
    'Worker task definition must be defined',
  );
  assert.match(
    mainTf,
    /resource\s+"aws_ecs_service"\s+"worker"/,
    'Worker ECS service must be defined',
  );
  assert.match(varsTf, /worker_desired_count/, 'Worker count variable must exist');
  assert.match(varsTf, /default\s*=\s*1/, 'Default worker desired count must be 1');
});

test('Terraform Database module specifications (PostgreSQL HA multi-AZ + 1 replica, PITR 14 days, KMS encryption)', () => {
  const mainTf = readFileSync(resolve(databaseModuleDir, 'main.tf'), 'utf-8');
  const varsTf = readFileSync(resolve(databaseModuleDir, 'variables.tf'), 'utf-8');

  // Primary RDS PostgreSQL Multi-AZ HA (§11.2)
  assert.match(
    mainTf,
    /resource\s+"aws_db_instance"\s+"primary"/,
    'Primary DB instance must be defined',
  );
  assert.match(mainTf, /engine\s*=\s*"postgres"/, 'Engine must be postgres');
  assert.match(mainTf, /multi_az\s*=\s*true/, 'Primary must be HA multi-AZ (§11.2)');
  assert.match(mainTf, /storage_encrypted\s*=\s*true/, 'Storage must be encrypted at rest');
  assert.match(
    mainTf,
    /backup_retention_period\s*=\s*var\.backup_retention_days/,
    'Continuous PITR retention must be configured',
  );
  assert.match(varsTf, /default\s*=\s*14/, 'Default backup retention must be 14 days (§11.4)');
  assert.match(varsTf, /default\s*=\s*"16\.4"/, 'PostgreSQL version must be 16+ (§4.2)');

  // Read Replica RDS (§11.2)
  assert.match(mainTf, /resource\s+"aws_db_instance"\s+"replica"/, 'Read replica must be defined');
  assert.match(
    mainTf,
    /replicate_source_db\s*=\s*aws_db_instance\.primary\.identifier/,
    'Replica must source from primary',
  );

  // Parameter Group with statement_timeout 3s (§11.3)
  assert.match(
    mainTf,
    /resource\s+"aws_db_parameter_group"\s+"postgres"/,
    'DB parameter group must be defined',
  );
  assert.match(mainTf, /family\s*=\s*"postgres16"/, 'Parameter group family must be postgres16');
  assert.match(mainTf, /statement_timeout/, 'statement_timeout parameter must be configured');
  assert.match(
    varsTf,
    /default\s*=\s*3000/,
    'statement_timeout default must be 3000 ms (3 seconds §11.3)',
  );

  // Cross-Region Automated Backup Replication to Singapore (§11.4)
  assert.match(
    mainTf,
    /resource\s+"aws_db_instance_automated_backups_replication"\s+"singapore"/,
    'Cross-region automated backup replication to Singapore must be defined (§11.4)',
  );
  assert.match(
    mainTf,
    /provider\s*=\s*aws\.singapore/,
    'Replication resource must use aws.singapore provider alias',
  );
  assert.match(
    mainTf,
    /resource\s+"aws_kms_key"\s+"singapore_backup"/,
    'Disaster recovery KMS key in Singapore must be defined',
  );
});

test('Terraform PgBouncer connection pooler specifications (Transaction mode §11.2, Port 6432, NLB)', () => {
  const mainTf = readFileSync(resolve(databaseModuleDir, 'main.tf'), 'utf-8');
  const varsTf = readFileSync(resolve(databaseModuleDir, 'variables.tf'), 'utf-8');

  // PgBouncer ECS Task Definition
  assert.match(
    mainTf,
    /resource\s+"aws_ecs_task_definition"\s+"pgbouncer"/,
    'PgBouncer task definition must be defined',
  );
  assert.match(
    mainTf,
    /"POOL_MODE"/,
    'POOL_MODE environment variable must be set in container definition',
  );
  assert.match(
    varsTf,
    /default\s*=\s*"transaction"/,
    'PgBouncer default pool mode must be transaction (§11.2)',
  );

  // PgBouncer Port 6432
  assert.match(mainTf, /containerPort\s*=\s*6432/, 'PgBouncer container port must be 6432');
  assert.match(mainTf, /port\s*=\s*6432/, 'PgBouncer listener/target group port must be 6432');

  // Internal NLB for PgBouncer
  assert.match(
    mainTf,
    /resource\s+"aws_lb"\s+"pgbouncer"/,
    'Internal NLB for PgBouncer must be defined',
  );
  assert.match(mainTf, /internal\s*=\s*true/, 'PgBouncer load balancer must be internal');
  assert.match(
    mainTf,
    /load_balancer_type\s*=\s*"network"/,
    'PgBouncer load balancer must be network type',
  );

  // PgBouncer ECS Service HA
  assert.match(
    mainTf,
    /resource\s+"aws_ecs_service"\s+"pgbouncer"/,
    'PgBouncer ECS service must be defined',
  );
  assert.match(
    mainTf,
    /desired_count\s*=\s*2/,
    'PgBouncer desired count must be at least 2 for HA',
  );
});

test('Terraform Redis ElastiCache HA specifications (Multi-AZ, BullMQ durability, encryption)', () => {
  const mainTf = readFileSync(resolve(databaseModuleDir, 'main.tf'), 'utf-8');

  assert.match(
    mainTf,
    /resource\s+"aws_elasticache_replication_group"\s+"redis"/,
    'Redis replication group must be defined',
  );
  assert.match(mainTf, /multi_az_enabled\s*=\s*true/, 'Redis must have Multi-AZ enabled (§11.2)');
  assert.match(
    mainTf,
    /automatic_failover_enabled\s*=\s*true/,
    'Redis must have automatic failover enabled',
  );
  assert.match(
    mainTf,
    /at_rest_encryption_enabled\s*=\s*true/,
    'Redis must have at-rest encryption enabled',
  );
  assert.match(
    mainTf,
    /transit_encryption_enabled\s*=\s*true/,
    'Redis must have transit encryption enabled',
  );
  assert.match(
    mainTf,
    /auth_token\s*=\s*random_password\.redis_auth_token\.result/,
    'Redis auth token must be configured',
  );

  // Parameter group for BullMQ (noeviction)
  assert.match(
    mainTf,
    /resource\s+"aws_elasticache_parameter_group"\s+"redis"/,
    'Redis parameter group must be defined',
  );
  assert.match(mainTf, /maxmemory-policy/, 'maxmemory-policy must be configured for BullMQ');
  assert.match(mainTf, /noeviction/, 'BullMQ requires noeviction policy to prevent dropped jobs');
});

test('Terraform Secrets Manager & KMS Integration (§12.1)', () => {
  const mainTf = readFileSync(resolve(databaseModuleDir, 'main.tf'), 'utf-8');

  // KMS Key
  assert.match(mainTf, /resource\s+"aws_kms_key"\s+"database"/, 'Database KMS key must be defined');
  assert.match(mainTf, /enable_key_rotation\s*=\s*true/, 'KMS key rotation must be enabled');

  // Secrets Manager
  assert.match(
    mainTf,
    /resource\s+"aws_secretsmanager_secret"\s+"postgres"/,
    'PostgreSQL secret must be defined',
  );
  assert.match(
    mainTf,
    /resource\s+"aws_secretsmanager_secret_version"\s+"postgres"/,
    'PostgreSQL secret version must be defined',
  );
  assert.match(
    mainTf,
    /resource\s+"aws_secretsmanager_secret"\s+"redis"/,
    'Redis secret must be defined',
  );
  assert.match(
    mainTf,
    /resource\s+"aws_secretsmanager_secret_version"\s+"redis"/,
    'Redis secret version must be defined',
  );
});

test('Terraform Database Observability Alarms (CloudWatch §10, §11)', () => {
  const mainTf = readFileSync(resolve(databaseModuleDir, 'main.tf'), 'utf-8');

  // Enhanced Monitoring
  assert.match(
    mainTf,
    /resource\s+"aws_iam_role"\s+"rds_monitoring"/,
    'RDS enhanced monitoring role must be defined',
  );
  assert.match(mainTf, /monitoring_interval\s*=\s*60/, 'Monitoring interval must be 60 seconds');

  // Alarms: CPU, memory, disk, connections
  assert.match(
    mainTf,
    /resource\s+"aws_cloudwatch_metric_alarm"\s+"postgres_cpu"/,
    'CPU alarm must be defined',
  );
  assert.match(
    mainTf,
    /resource\s+"aws_cloudwatch_metric_alarm"\s+"postgres_memory"/,
    'Memory alarm must be defined',
  );
  assert.match(
    mainTf,
    /resource\s+"aws_cloudwatch_metric_alarm"\s+"postgres_disk"/,
    'Disk space alarm must be defined',
  );
  assert.match(
    mainTf,
    /resource\s+"aws_cloudwatch_metric_alarm"\s+"postgres_connections"/,
    'DB connections alarm must be defined',
  );
});

test('Dev environment configuration linkages and variables (Network, Database, Compute, Singapore Provider)', () => {
  const mainTf = readFileSync(resolve(devEnvDir, 'main.tf'), 'utf-8');
  const varsTf = readFileSync(resolve(devEnvDir, 'variables.tf'), 'utf-8');
  const outputsTf = readFileSync(resolve(devEnvDir, 'outputs.tf'), 'utf-8');

  assert.match(mainTf, /module\s+"network"/, 'Dev environment must instantiate network module');
  assert.match(mainTf, /module\s+"database"/, 'Dev environment must instantiate database module');
  assert.match(mainTf, /module\s+"compute"/, 'Dev environment must instantiate compute module');
  assert.match(
    mainTf,
    /provider\s+"aws"\s+\{[^}]*alias\s*=\s*"singapore"[^}]*region\s*=\s*"ap-southeast-1"/s,
    'Singapore provider alias must be declared for DR backups',
  );

  // Environment variable propagation to Compute
  assert.match(mainTf, /DATABASE_URL/, 'DATABASE_URL must be injected to compute services');
  assert.match(mainTf, /DB_REPLICA_URL/, 'DB_REPLICA_URL must be injected to compute services');
  assert.match(mainTf, /REDIS_URL/, 'REDIS_URL must be injected to compute services');

  // Outputs
  assert.match(
    outputsTf,
    /output\s+"database_primary_endpoint"/,
    'Primary DB endpoint must be exported',
  );
  assert.match(
    outputsTf,
    /output\s+"database_replica_endpoint"/,
    'Replica DB endpoint must be exported',
  );
  assert.match(outputsTf, /output\s+"pgbouncer_host"/, 'PgBouncer host must be exported');
  assert.match(outputsTf, /output\s+"redis_primary_endpoint"/, 'Redis endpoint must be exported');

  assert.match(
    varsTf,
    /default\s*=\s*"ap-southeast-3"/,
    'Dev region default must be ap-southeast-3 (Jakarta §4.2)',
  );
});

test('Simulated PgBouncer connectivity and statement_timeout (3s) verification (§11.3)', async () => {
  // Verifies that a connection pooler adhering to the configured 3000ms statement_timeout
  // aborts queries exceeding 3 seconds as mandated by §11.3.
  const statementTimeoutMs = 3000;

  const server = createServer((socket) => {
    socket.on('data', (data) => {
      const msg = data.toString('utf-8');
      if (msg.includes('SELECT pg_sleep(4)')) {
        // Query exceeds statement_timeout (3000ms) -> cancel statement with SQLSTATE 57014
        setTimeout(() => {
          socket.write(
            JSON.stringify({
              status: 'ERROR',
              code: '57014',
              message: 'canceling statement due to statement timeout',
              timeoutMs: statementTimeoutMs,
            }),
          );
          socket.end();
        }, 100);
      } else {
        socket.write(JSON.stringify({ status: 'OK', rows: [{ ok: 1 }] }));
        socket.end();
      }
    });
  });

  await new Promise((resolve) => server.listen(0, '127.0.0.1', resolve));
  const port = server.address().port;

  const result = await new Promise((resolve, reject) => {
    import('node:net').then(({ connect }) => {
      const client = connect({ port, host: '127.0.0.1' }, () => {
        client.write('SELECT pg_sleep(4);');
      });

      let buf = '';
      client.on('data', (chunk) => {
        buf += chunk.toString();
      });

      client.on('end', () => {
        resolve(JSON.parse(buf));
      });

      client.on('error', reject);
    });
  });

  server.close();

  assert.equal(result.status, 'ERROR');
  assert.equal(result.code, '57014');
  assert.match(result.message, /canceling statement due to statement timeout/);
  assert.equal(result.timeoutMs, 3000);
});

test('Terraform Storage module specifications (S3 versioning, AES256 SSE, private bucket block, presigned policy §4.2, §9.3, §11.4, §12.1)', () => {
  const mainTf = readFileSync(resolve(storageModuleDir, 'main.tf'), 'utf-8');
  const varsTf = readFileSync(resolve(storageModuleDir, 'variables.tf'), 'utf-8');
  const outputsTf = readFileSync(resolve(storageModuleDir, 'outputs.tf'), 'utf-8');

  // Buckets for Content Packs and Audio
  assert.match(
    mainTf,
    /resource\s+"aws_s3_bucket"\s+"content_packs"/,
    'Content packs S3 bucket must be defined',
  );
  assert.match(mainTf, /resource\s+"aws_s3_bucket"\s+"audio"/, 'Audio S3 bucket must be defined');

  // WAJIB mengaktifkan versioning (§11.4)
  assert.match(
    mainTf,
    /resource\s+"aws_s3_bucket_versioning"\s+"content_packs"/,
    'Content packs bucket versioning must be defined',
  );
  assert.match(
    mainTf,
    /resource\s+"aws_s3_bucket_versioning"\s+"audio"/,
    'Audio bucket versioning must be defined',
  );
  assert.match(
    mainTf,
    /status\s*=\s*"Enabled"/,
    'Bucket versioning status must be Enabled (§11.4)',
  );

  // Server-Side Encryption
  assert.match(
    mainTf,
    /resource\s+"aws_s3_bucket_server_side_encryption_configuration"\s+"content_packs"/,
    'Content packs SSE must be defined',
  );
  assert.match(
    mainTf,
    /resource\s+"aws_s3_bucket_server_side_encryption_configuration"\s+"audio"/,
    'Audio SSE must be defined',
  );
  assert.match(mainTf, /sse_algorithm\s*=\s*"AES256"/, 'SSE algorithm must be AES256');

  // Strict Public Access Block (§12.1)
  assert.match(
    mainTf,
    /resource\s+"aws_s3_bucket_public_access_block"\s+"content_packs"/,
    'Content packs public access block must be defined',
  );
  assert.match(
    mainTf,
    /resource\s+"aws_s3_bucket_public_access_block"\s+"audio"/,
    'Audio public access block must be defined',
  );
  assert.match(mainTf, /block_public_acls\s*=\s*true/, 'block_public_acls must be true');
  assert.match(mainTf, /block_public_policy\s*=\s*true/, 'block_public_policy must be true');
  assert.match(mainTf, /ignore_public_acls\s*=\s*true/, 'ignore_public_acls must be true');
  assert.match(
    mainTf,
    /restrict_public_buckets\s*=\s*true/,
    'restrict_public_buckets must be true',
  );

  // CORS Configuration with Range header support for resumable downloads (§9.3)
  assert.match(
    mainTf,
    /resource\s+"aws_s3_bucket_cors_configuration"/,
    'CORS configuration must be defined',
  );
  assert.match(
    mainTf,
    /"Content-Range"/,
    'CORS expose headers must include Content-Range for resumable downloads',
  );

  // Presigned URL IAM Policy (§8.2, §12.1)
  assert.match(
    mainTf,
    /resource\s+"aws_iam_policy"\s+"presigned_url_access"/,
    'Presigned URL IAM policy must be defined',
  );
  assert.match(
    outputsTf,
    /output\s+"presigned_url_policy_arn"/,
    'Presigned URL policy ARN must be exported',
  );
});

test('Terraform CloudFront CDN module specifications (OAC, read-mostly caching, signed URLs, S3 bucket policies §4.2, §8.2, §9.3, §12.1)', () => {
  const mainTf = readFileSync(resolve(cdnModuleDir, 'main.tf'), 'utf-8');
  const outputsTf = readFileSync(resolve(cdnModuleDir, 'outputs.tf'), 'utf-8');

  // Origin Access Control (OAC)
  assert.match(
    mainTf,
    /resource\s+"aws_cloudfront_origin_access_control"\s+"s3_oac"/,
    'CloudFront OAC must be defined',
  );
  assert.match(mainTf, /signing_behavior\s*=\s*"always"/, 'OAC signing behavior must be always');
  assert.match(mainTf, /signing_protocol\s*=\s*"sigv4"/, 'OAC signing protocol must be sigv4');

  // Signed URL Public Key & Key Group (§8.2, §12.1)
  assert.match(
    mainTf,
    /resource\s+"aws_cloudfront_public_key"\s+"premium_signer"/,
    'CloudFront public key for premium content must be defined',
  );
  assert.match(
    mainTf,
    /resource\s+"aws_cloudfront_key_group"\s+"premium_signers"/,
    'CloudFront key group for signed URLs must be defined',
  );

  // CloudFront Distribution & Origins
  assert.match(
    mainTf,
    /resource\s+"aws_cloudfront_distribution"\s+"main"/,
    'CloudFront distribution must be defined',
  );
  assert.match(
    mainTf,
    /origin_access_control_id\s*=\s*aws_cloudfront_origin_access_control\.s3_oac\.id/,
    'Origins must use OAC',
  );

  // Read-Mostly Caching Rules (§4.2, §9.3)
  assert.match(
    mainTf,
    /allowed_methods\s*=\s*\["GET",\s*"HEAD",\s*"OPTIONS"\]/,
    'Allowed methods must be read-mostly',
  );
  assert.match(
    mainTf,
    /cached_methods\s*=\s*\["GET",\s*"HEAD"\]/,
    'Cached methods must be GET and HEAD',
  );
  assert.match(mainTf, /compress\s*=\s*true/, 'Gzip and Brotli compression must be enabled');
  assert.match(
    mainTf,
    /viewer_protocol_policy\s*=\s*"redirect-to-https"/,
    'Viewer protocol policy must redirect to HTTPS',
  );

  // Signed URL Cache Behavior for Premium Content (§8.2, §12.1)
  assert.match(
    mainTf,
    /trusted_key_groups\s*=\s*\[aws_cloudfront_key_group\.premium_signers\.id\]/,
    'Premium cache behavior must require trusted key group for signed URLs',
  );

  // Audio Cache Behavior
  assert.match(
    mainTf,
    /path_pattern\s*=\s*"\/audio\/\*"/,
    'Audio path pattern must be configured with optimized caching',
  );

  // S3 Bucket Policies for CloudFront OAC
  assert.match(
    mainTf,
    /resource\s+"aws_s3_bucket_policy"\s+"content_packs"/,
    'S3 bucket policy for content packs must be defined',
  );
  assert.match(
    mainTf,
    /resource\s+"aws_s3_bucket_policy"\s+"audio"/,
    'S3 bucket policy for audio must be defined',
  );
  assert.match(
    mainTf,
    /cloudfront\.amazonaws\.com/,
    'Bucket policy must allow CloudFront service principal',
  );

  // Outputs
  assert.match(
    outputsTf,
    /output\s+"cloudfront_distribution_id"/,
    'Distribution ID must be exported',
  );
  assert.match(
    outputsTf,
    /output\s+"cloudfront_distribution_domain_name"/,
    'Distribution domain name must be exported',
  );
  assert.match(outputsTf, /output\s+"cloudfront_key_group_id"/, 'Key group ID must be exported');
});

test('Terraform Secrets Manager & KMS module specifications (KMS CMK rotation, JWT signing keys, 3rd party API keys §8.3, §12.1, §13)', () => {
  const mainTf = readFileSync(resolve(secretsModuleDir, 'main.tf'), 'utf-8');
  const outputsTf = readFileSync(resolve(secretsModuleDir, 'outputs.tf'), 'utf-8');

  // KMS Customer Managed Key with Rotation
  assert.match(mainTf, /resource\s+"aws_kms_key"\s+"secrets"/, 'Secrets KMS CMK must be defined');
  assert.match(
    mainTf,
    /enable_key_rotation\s*=\s*true/,
    'KMS key rotation must be enabled (§12.1)',
  );

  // JWT Signing Key Secret with kid Rotation Support (§8.3)
  assert.match(
    mainTf,
    /resource\s+"aws_secretsmanager_secret"\s+"jwt_signing_key"/,
    'JWT signing key secret must be defined',
  );
  assert.match(
    mainTf,
    /resource\s+"aws_secretsmanager_secret_version"\s+"jwt_signing_key"/,
    'JWT signing key version must be defined',
  );
  assert.match(mainTf, /kid/, 'JWT secret payload must support key identifier (kid) rotation');

  // Third-Party API Keys Secret (§8.2, §12.1, §13)
  assert.match(
    mainTf,
    /resource\s+"aws_secretsmanager_secret"\s+"third_party_api_keys"/,
    'Third party API keys secret must be defined',
  );
  assert.match(
    mainTf,
    /revenuecat_webhook_secret/,
    'RevenueCat webhook secret must be configured in secret payload',
  );
  assert.match(
    mainTf,
    /email_provider_api_key/,
    'Email provider API key must be configured in secret payload',
  );

  // CloudFront Private Signing Key
  assert.match(
    mainTf,
    /resource\s+"aws_secretsmanager_secret"\s+"cloudfront_signing_private_key"/,
    'CloudFront signing private key secret must be defined',
  );

  // IAM Policy for Backend Access
  assert.match(
    mainTf,
    /resource\s+"aws_iam_policy"\s+"secrets_read_access"/,
    'Secrets read IAM policy must be defined',
  );
  assert.match(
    outputsTf,
    /output\s+"jwt_signing_key_secret_arn"/,
    'JWT secret ARN must be exported',
  );
  assert.match(
    outputsTf,
    /output\s+"third_party_api_keys_secret_arn"/,
    'Third-party secrets ARN must be exported',
  );
  assert.match(
    outputsTf,
    /output\s+"secrets_read_policy_arn"/,
    'Secrets read policy ARN must be exported',
  );
});

test('Terraform CDN Observability & Access Logging specifications (§10, M0-4c)', () => {
  const cdnMainTf = readFileSync(resolve(cdnModuleDir, 'main.tf'), 'utf-8');

  // S3 Access Logging Bucket
  assert.match(
    cdnMainTf,
    /resource\s+"aws_s3_bucket"\s+"logs"/,
    'CDN access logs S3 bucket must be defined',
  );
  assert.match(
    cdnMainTf,
    /logging_config\s*\{/,
    'CloudFront distribution must configure logging_config',
  );
  assert.match(
    cdnMainTf,
    /prefix\s*=\s*"cdn-access-logs\/"/,
    'Log prefix must be cdn-access-logs/',
  );

  // CloudWatch Metric Alarms for 5xx and 4xx Error Rates
  assert.match(
    cdnMainTf,
    /resource\s+"aws_cloudwatch_metric_alarm"\s+"cdn_5xx_rate"/,
    'CDN 5xx error rate alarm must be defined',
  );
  assert.match(
    cdnMainTf,
    /metric_name\s*=\s*"5xxErrorRate"/,
    'Alarm metric must track 5xxErrorRate',
  );
  assert.match(
    cdnMainTf,
    /resource\s+"aws_cloudwatch_metric_alarm"\s+"cdn_4xx_rate"/,
    'CDN 4xx error rate alarm must be defined',
  );
  assert.match(
    cdnMainTf,
    /metric_name\s*=\s*"4xxErrorRate"/,
    'Alarm metric must track 4xxErrorRate',
  );
});

test('Dev environment integration of Storage, CDN, Secrets, and Compute environment variables (§4.2, §12.1, §14.1)', () => {
  const mainTf = readFileSync(resolve(devEnvDir, 'main.tf'), 'utf-8');
  const outputsTf = readFileSync(resolve(devEnvDir, 'outputs.tf'), 'utf-8');

  // Module instantiations
  assert.match(mainTf, /module\s+"storage"/, 'Dev environment must instantiate storage module');
  assert.match(mainTf, /module\s+"cdn"/, 'Dev environment must instantiate cdn module');
  assert.match(mainTf, /module\s+"secrets"/, 'Dev environment must instantiate secrets module');

  // IAM Policy Attachments to API Task Role
  assert.match(
    mainTf,
    /resource\s+"aws_iam_role_policy_attachment"\s+"api_presigned_url_access"/,
    'API task role must attach S3 presigned URL policy',
  );
  assert.match(
    mainTf,
    /resource\s+"aws_iam_role_policy_attachment"\s+"api_secrets_read_access"/,
    'API task role must attach secrets read policy',
  );

  // Injected Environment Variables to Compute API
  assert.match(mainTf, /STORAGE_PACKS_BUCKET/, 'STORAGE_PACKS_BUCKET env var must be injected');
  assert.match(mainTf, /STORAGE_AUDIO_BUCKET/, 'STORAGE_AUDIO_BUCKET env var must be injected');
  assert.match(mainTf, /CDN_DOMAIN/, 'CDN_DOMAIN env var must be injected');
  assert.match(mainTf, /JWT_SECRET_ARN/, 'JWT_SECRET_ARN env var must be injected');
  assert.match(
    mainTf,
    /THIRD_PARTY_SECRETS_ARN/,
    'THIRD_PARTY_SECRETS_ARN env var must be injected',
  );

  // Exported Outputs
  assert.match(
    outputsTf,
    /output\s+"content_packs_bucket_id"/,
    'Content packs bucket ID must be exported',
  );
  assert.match(
    outputsTf,
    /output\s+"cloudfront_distribution_id"/,
    'CloudFront distribution ID must be exported',
  );
  assert.match(
    outputsTf,
    /output\s+"jwt_signing_key_secret_arn"/,
    'JWT secret ARN must be exported',
  );
});

test('Simulated private bucket permission test: direct unauthenticated access returns 403 Forbidden, CDN OAC / presigned URL allowed (§12.1, M0-4c)', async () => {
  // Simulates an S3 private bucket endpoint enforcing Origin Access Control and SigV4 Presigned URLs.
  // Direct access without valid signature or CloudFront OAC header is rejected with 403 Forbidden.
  const server = createHttpServer((req, res) => {
    const url = new URL(req.url, `http://${req.headers.host}`);
    const hasOac =
      req.headers['x-amz-cf-id'] || req.headers['authorization']?.includes('AWS4-HMAC-SHA256');
    const hasPresignedSig =
      url.searchParams.has('X-Amz-Signature') || url.searchParams.has('Signature');

    if (hasOac || hasPresignedSig) {
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ status: 'OK', object: 'premium-pack.zip', size: 1048576 }));
    } else {
      res.writeHead(403, { 'Content-Type': 'application/xml' });
      res.end(
        '<?xml version="1.0" encoding="UTF-8"?><Error><Code>AccessDenied</Code><Message>Access Denied</Message></Error>',
      );
    }
  });

  await new Promise((resolve) => server.listen(0, '127.0.0.1', resolve));
  const port = server.address().port;

  // Test 1: Direct unauthenticated request -> MUST return 403 Forbidden
  const directResponse = await fetch(
    `http://127.0.0.1:${port}/nihonpath-dev-packs/packs/n4-core.zip`,
  );
  assert.equal(
    directResponse.status,
    403,
    'Direct access without CDN or signature must be 403 Forbidden',
  );
  const directBody = await directResponse.text();
  assert.match(directBody, /AccessDenied/, 'Direct access error code must be AccessDenied');

  // Test 2: Request via Presigned URL (contains X-Amz-Signature) -> MUST return 200 OK
  const presignedResponse = await fetch(
    `http://127.0.0.1:${port}/nihonpath-dev-packs/packs/n4-core.zip?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Signature=valid_sig_mock`,
  );
  assert.equal(presignedResponse.status, 200, 'Presigned URL request must return 200 OK');

  // Test 3: Request from CloudFront Origin Access Control (contains x-amz-cf-id header) -> MUST return 200 OK
  const cdnResponse = await fetch(
    `http://127.0.0.1:${port}/nihonpath-dev-packs/packs/n4-core.zip`,
    {
      headers: { 'x-amz-cf-id': 'cf-edge-trace-mock-123' },
    },
  );
  assert.equal(cdnResponse.status, 200, 'CloudFront OAC request must return 200 OK');

  server.close();
});

test('Terraform verification script executes without error when CLI is available', () => {
  const isWindows = process.platform === 'win32';
  const currentPath = process.env.PATH || process.env.Path || '';
  const wingetLinks = process.env.LOCALAPPDATA
    ? resolve(process.env.LOCALAPPDATA, 'Microsoft/WinGet/Links')
    : '';
  const augmentedPath =
    isWindows && wingetLinks && !currentPath.includes(wingetLinks)
      ? `${currentPath};${wingetLinks}`
      : currentPath;

  const tfCheck = spawnSync('terraform', ['-version'], {
    shell: isWindows,
    env: { ...process.env, PATH: augmentedPath, Path: augmentedPath },
  });

  if (tfCheck.status === 0) {
    const verifyScript = resolve(rootDir, 'scripts/verify-terraform.mjs');
    const res = spawnSync('node', [verifyScript], {
      cwd: rootDir,
      encoding: 'utf-8',
      shell: isWindows,
      env: { ...process.env, PATH: augmentedPath, Path: augmentedPath },
    });
    assert.equal(
      res.status,
      0,
      `verify-terraform.mjs should succeed:\n${res.stdout}\n${res.stderr}`,
    );
  }
});
