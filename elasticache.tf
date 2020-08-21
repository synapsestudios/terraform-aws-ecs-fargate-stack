locals {
  redis_cluster_id = var.use_redis == true ? aws_elasticache_replication_group.this[0].member_clusters : ["null"]
  redis_azs        = length(var.redis_cluster_mode) == 0 ? slice(module.vpc.azs, 0, var.redis_instance_count) : null
}

######################################################
# ElastiCache - Redis Replication Group & Cluster Mode
######################################################
resource "aws_elasticache_replication_group" "this" {
  count = var.use_redis == true ? 1 : 0

  apply_immediately             = true
  automatic_failover_enabled    = length(var.redis_cluster_mode) == 0 ? false : true
  engine                        = "redis"
  engine_version                = var.redis_engine_version
  number_cache_clusters         = length(var.redis_cluster_mode) == 0 ? var.redis_instance_count : null
  node_type                     = var.redis_instance_type
  port                          = 6379
  replication_group_description = "${title(var.environment_name)} Redis Replication Group"
  replication_group_id          = var.namespace
  security_group_ids            = [module.vpc.default_security_group_id, aws_security_group.redis[0].id]
  subnet_group_name             = module.vpc.elasticache_subnet_group_name
  availability_zones            = local.redis_azs

  dynamic "cluster_mode" {
    for_each = var.redis_cluster_mode
    content {
      replicas_per_node_group = cluster_mode.value["replicas_per_node_group"]
      num_node_groups         = cluster_mode.value["num_node_groups"]
    }
  }
  tags = var.tags
}

resource "aws_route53_record" "redis_replica_group" {
  count = var.use_redis == true ? 1 : 0

  zone_id = local.zone_id
  name    = "redis"
  type    = "CNAME"
  ttl     = "300"
  records = aws_elasticache_replication_group.this[0].primary_endpoint_address == null ? [aws_elasticache_replication_group.this[0].configuration_endpoint_address] : [aws_elasticache_replication_group.this[0].primary_endpoint_address]
}

