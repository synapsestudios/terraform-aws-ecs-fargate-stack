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

output "grafana_alb_response_time_bargauge" {
  description = "Grafan Meter Panel for ALB Response Times."
  value       = module.grafana_alb_response_time_bargauge.panel
}

output "grafna_alb_request_count_target_response_time" {
  description = "Grafana Panel for ALB RequestCount / TargetResponseTime."
  value       = module.grafana_alb_request_response.panel
}

output "grafana_alb_http_target_response_code" {
  description = "Grafana Panel for ALB HTTP Target Response Codes."
  value       = module.grafana_alb_http_target_response_code.panel
}

output "grafana_alb_http_response_code" {
  description = "Grafana Panel for ALB HTTP Response Codes."
  value       = module.grafana_alb_http_response_code.panel
}

output "grafana_alb_connection_count" {
  description = "Grafana Panel for ALB Connection Counts."
  value       = module.grafana_alb_connection_count.panel
}

output "grafana_rds_cpu_utilization" {
  description = "Grafana Panel for RDS CPU Utilization."
  value       = module.grafana_rds_cpu_utilization.panel
}

output "grafana_rds_cpu_credit" {
  description = "Grafana Panel for RDS CPU Credit Usage."
  value       = module.grafana_rds_cpu_credit.panel
}

output "grafana_rds_available_memory" {
  description = "Grafana Panel for RDS Available Memory."
  value       = module.grafana_rds_available_memory.panel
}

output "grafana_rds_swap_usage" {
  description = "Grafana Panel for RDS Swap Usage."
  value       = module.grafana_rds_swap_usage.panel
}

output "grafana_rds_storage_space" {
  description = "Grafana Panel for RDS Storage Space."
  value       = module.grafana_rds_storage_space.panel
}

output "grafana_rds_disk_iops" {
  description = "Grafana Panel for RDS Disk IOPS."
  value       = module.grafana_rds_disk_iops.panel
}

output "grafana_rds_disk_latency" {
  description = "Grafana Panel for RDS Disk Latency."
  value       = module.grafana_rds_disk_latency.panel
}

output "grafana_rds_disk_queue_depth" {
  description = "Grafana Panel for RDS Disk Queue Depth."
  value       = module.grafana_rds_disk_queue_depth.panel
}

output "grafana_rds_disk_throughput" {
  description = "Grafana Panel for RDS Disk Throughput."
  value       = module.grafana_rds_disk_throughput.panel
}

output "grafana_rds_network_traffic" {
  description = "Grafana Panel for RDS Network Traffic."
  value       = module.grafana_rds_network_traffic.panel
}

output "grafana_redis_cache" {
  description = "Grafana Panel for Redis Cache Stats."
  value       = module.grafana_redis_cache.panel
}

output "grafana_redis_commands" {
  description = "Grafana Panel for Redis Command Stats."
  value       = module.grafana_redis_commands.panel
}

output "grafana_redis_connections" {
  description = "Grafana Panel for Redis Connections."
  value       = module.grafana_redis_connections.panel
}

output "grafana_redis_items" {
  description = "Grafana Panel for Redis Save In Progress / Current Connections."
  value       = module.grafana_redis_items.panel
}

output "grafana_redis_bytes_used_for_cache_and_replication" {
  description = "Grafana Panel for Redis Bytes Used For Cache / Bytes Used For Replication."
  value       = module.grafana_redis_bytes_used_for_cache_and_replication.panel
}

output "grafana_redis_hyperlog_replication_lag" {
  description = "Grafana Panel for Redis HyperLog / Replication Lag."
  value       = module.grafana_redis_hyperlog_replication_lag.panel
}

output "grafana_redis_cpu_utilization" {
  description = "Grafana Panel for Redis CPU Utilization."
  value       = module.grafana_redis_cpu_utilization.panel
}

output "grafana_redis_network_traffic" {
  description = "Grafana Panel for Redis Network Traffic."
  value       = module.grafana_redis_network_traffic.panel
}

output "grafana_redis_memory_and_swap" {
  description = "Grafana Panel for Redis Freeable Memory / Swap Usage."
  value       = module.grafana_redis_memory_and_swap.panel
}

output "grafana_es_cluster_status" {
  description = "Grafana Panel for ElasticSearch Cluster Status."
  value       = module.grafana_es_cluster_status.panel
}

output "grafana_es_total_nodes" {
  description = "Grafana Panel for ElasticSearch Total Nodes."
  value       = module.grafana_es_total_nodes.panel
}

output "grafana_es_cpu_utilization_data_nodes" {
  description = "Grafana Panel for ElasticSearch CPU Utilization On All Data Nodes."
  value       = module.grafana_es_cpu_utilization_data_nodes.panel
}

output "grafana_es_free_storage_space" {
  description = "Grafana Panel for ElasticSearch Free Storage Space."
  value       = module.grafana_es_free_storage_space.panel
}

output "grafana_es_searchable_documents" {
  description = "Grafana Panel for ElasticSearch Searchable Documents."
  value       = module.grafana_es_searchable_documents.panel
}

output "grafana_es_deleted_documents" {
  description = "Grafana Panel for ElasticSearch Deleted Documents."
  value       = module.grafana_es_deleted_documents.panel
}

output "grafana_es_indexing_rate" {
  description = "Grafana Panel for ElasticSearch Indexing Rate."
  value       = module.grafana_es_indexing_rate.panel
}

output "grafana_es_indexing_latency" {
  description = "Grafana Panel for ElasticSearch Indexing Latency."
  value       = module.grafana_es_indexing_latency.panel
}

output "grafana_es_search_rate" {
  description = "Grafana Panel for ElasticSearch Search Rate."
  value       = module.grafana_es_search_rate.panel
}

output "grafana_es_search_latency" {
  description = "Grafana Panel for ElasticSearch Search Latency."
  value       = module.grafana_es_search_latency.panel
}

output "grafana_es_http_response_codes" {
  description = "Grafana Panel for ElasticSearch HTTP Response Codes."
  value       = module.grafana_es_http_response_codes.panel
}

output "grafana_es_invalid_host_headers" {
  description = "Grafana Panel for ElasticSearch Invalid Host Header Requests."
  value       = module.grafana_es_invalid_host_headers.panel
}

output "grafana_es_thread_pools" {
  description = "Grafana Panel for ElasticSearch Thread Pools."
  value       = module.grafana_es_thread_pools.panel
}



