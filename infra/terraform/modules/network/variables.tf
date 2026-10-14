variable "name_prefix" {
  description = "Prefix used for naming network resources"
  type        = string
  default     = "nihonpath"
}

variable "environment" {
  description = "Deployment environment name (e.g. dev, staging, prod)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones in Jakarta region (ap-southeast-3)"
  type        = list(string)
  default     = ["ap-southeast-3a", "ap-southeast-3b", "ap-southeast-3c"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (multi-AZ)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets (multi-AZ)"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
}

variable "single_nat_gateway" {
  description = "Use a single NAT Gateway across private subnets for dev cost efficiency"
  type        = bool
  default     = true
}

variable "api_container_port" {
  description = "Target port exposed by the API container"
  type        = number
  default     = 3000
}

variable "tags" {
  description = "Additional tags for network resources"
  type        = map(string)
  default     = {}
}
