import test from 'node:test';
import assert from 'node:assert/strict';
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
const devEnvDir = resolve(terraformDir, 'environments/dev');

test('Terraform folder structure and mandatory files (§14.1, M0-4a)', () => {
  const requiredFiles = [
    resolve(networkModuleDir, 'main.tf'),
    resolve(networkModuleDir, 'variables.tf'),
    resolve(networkModuleDir, 'outputs.tf'),
    resolve(computeModuleDir, 'main.tf'),
    resolve(computeModuleDir, 'variables.tf'),
    resolve(computeModuleDir, 'outputs.tf'),
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

test('Dev environment configuration linkages and variables', () => {
  const mainTf = readFileSync(resolve(devEnvDir, 'main.tf'), 'utf-8');
  const varsTf = readFileSync(resolve(devEnvDir, 'variables.tf'), 'utf-8');

  assert.match(mainTf, /module\s+"network"/, 'Dev environment must instantiate network module');
  assert.match(mainTf, /module\s+"compute"/, 'Dev environment must instantiate compute module');
  assert.match(
    varsTf,
    /default\s*=\s*"ap-southeast-3"/,
    'Dev region default must be ap-southeast-3 (Jakarta §4.2)',
  );
});

test('Terraform verification script executes without error when CLI is available', () => {
  const isWindows = process.platform === 'win32';
  const tfCheck = spawnSync('terraform', ['-version'], { shell: isWindows });

  if (tfCheck.status === 0) {
    const verifyScript = resolve(rootDir, 'scripts/verify-terraform.mjs');
    const res = spawnSync('node', [verifyScript], {
      cwd: rootDir,
      encoding: 'utf-8',
      shell: isWindows,
      env: process.env,
    });
    assert.equal(
      res.status,
      0,
      `verify-terraform.mjs should succeed:\n${res.stdout}\n${res.stderr}`,
    );
  }
});
