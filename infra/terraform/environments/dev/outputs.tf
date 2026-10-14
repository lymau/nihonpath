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
