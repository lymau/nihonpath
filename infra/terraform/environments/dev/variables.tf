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

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
