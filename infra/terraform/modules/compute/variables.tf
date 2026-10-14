variable "name_prefix" {
  description = "Prefix used for naming compute resources"
  type        = string
  default     = "nihonpath"
}

variable "environment" {
  description = "Deployment environment name (e.g. dev, staging, prod)"
  type        = string
}

variable "aws_region" {
  description = "AWS Region (ap-southeast-3 for Jakarta)"
  type        = string
  default     = "ap-southeast-3"
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnets used by the Application Load Balancer"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Private subnets where container tasks run"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "Security group ID for the ALB"
  type        = string
}

variable "api_security_group_id" {
  description = "Security group ID for the API ECS service"
  type        = string
}

variable "worker_security_group_id" {
  description = "Security group ID for the Worker ECS service"
  type        = string
}

variable "api_image" {
  description = "Docker image for the API service"
  type        = string
  default     = "public.ecr.aws/ecs-sample-image/amazon-ecs-sample:latest"
}

variable "worker_image" {
  description = "Docker image for the BullMQ worker service"
  type        = string
  default     = "public.ecr.aws/ecs-sample-image/amazon-ecs-sample:latest"
}

variable "api_container_port" {
  description = "Port exposed by the API container"
  type        = number
  default     = 3000
}

variable "api_cpu" {
  description = "CPU units allocated for API task (256 = 0.25 vCPU)"
  type        = number
  default     = 256
}

variable "api_memory" {
  description = "Memory (in MiB) allocated for API task"
  type        = number
  default     = 512
}

variable "api_min_capacity" {
  description = "Minimum number of API tasks (autoscale lower bound)"
  type        = number
  default     = 2
}

variable "api_max_capacity" {
  description = "Maximum number of API tasks (autoscale upper bound)"
  type        = number
  default     = 5
}

variable "api_target_cpu_utilization" {
  description = "Target CPU utilization percentage for API autoscaling (§11.2)"
  type        = number
  default     = 60.0
}

variable "worker_cpu" {
  description = "CPU units allocated for BullMQ worker task"
  type        = number
  default     = 256
}

variable "worker_memory" {
  description = "Memory (in MiB) allocated for BullMQ worker task"
  type        = number
  default     = 512
}

variable "worker_desired_count" {
  description = "Desired number of BullMQ worker tasks"
  type        = number
  default     = 1
}

variable "log_retention_in_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 30
}

variable "api_environment_variables" {
  description = "Environment variables for the API container"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "worker_environment_variables" {
  description = "Environment variables for the BullMQ worker container"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "tags" {
  description = "Additional tags for compute resources"
  type        = map(string)
  default     = {}
}
