output "cluster_name" {
  description = "ECS Cluster name for this environment."
  value       = aws_ecs_cluster.this.name
}

output "ecs_cluster_arn" {
  description = "ECS Cluster ARN for this environment."
  value       = aws_ecs_cluster.this.arn
}

output "vpc_id" {
  description = "VPC ID Created for this environment."
  value       = module.vpc.vpc_id
}

output "dns_zone_id" {
  description = "Route53 DNS Zone ID."
  value       = var.private_dns == true ? aws_route53_zone.this[0].id : data.aws_route53_zone.this[0].id
}

output "private_subnets" {
  description = "List of Private subnet IDs."
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "List of Public subnet IDs."
  value       = module.vpc.public_subnets
}

output "database_subnets" {
  description = "List of Database subnet IDs."
  value       = module.vpc.database_subnets
}

output "database_security_group" {
  description = "Database SecurityGroup ID."
  value       = aws_security_group.database.id
}

output "database_endpoint" {
  description = "Database Endpoint."
  value       = length(aws_db_instance.this) >= 1 ? aws_db_instance.this[0].address : aws_rds_cluster.this[0].endpoint
}

output "database_endpoint_reader" {
  description = "Database Endpoint."
  value       = length(aws_rds_cluster_instance.this) >= 1 ? aws_rds_cluster.this[0].reader_endpoint : null
}

output "redis_security_group" {
  description = "Redis SecurityGroup ID."
  value       = var.use_redis == true ? aws_security_group.redis[0].id : null
}

output "elasticsearch_security_group" {
  description = "ElasticSeasrch SecurityGroup ID."
  value       = var.use_elasticsearch == true ? aws_security_group.elasticsearch[0].id : null
}

output "ecs_tasks_security_group" {
  description = "ECS Tasks SecurityGroup ID."
  value       = aws_security_group.ecs_tasks.id
}

output "load_balancer_security_group" {
  description = "LoadBalancer SecurityGroup ID."
  value       = aws_security_group.load_balancer.id
}

output "load_balancer_arn" {
  description = "LoadBalancer ARN."
  value       = aws_lb.this.arn
}

output "database_address" {
  description = "Database endpoint address."
  value       = length(aws_db_instance.this) >= 1 ? aws_db_instance.this[0].address : null
}

output "es_endpoint" {
  description = "ElasticSearch domain-specific endpoint used to submit index, search, and data upload requests."
  value       = var.use_elasticsearch == true ? aws_elasticsearch_domain.this[0].domain_name : null
}

output "http_listener_arn" {
  description = "HTTP Listener ARN."
  value       = aws_lb_listener.http.arn
}

output "https_listener_arn" {
  description = "HTTPS Listener ARN."
  value       = aws_lb_listener.https.arn
}

output "service_discovery_namespace_id" {
  description = "Service Discovery Namespace ID."
  value       = var.use_service_discovery == true ? aws_service_discovery_private_dns_namespace.this[0].id : null
}