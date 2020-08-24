locals {
  loadbalancer_name = aws_lb.this.arn_suffix
  region            = data.aws_region.current.name
  name              = aws_lb.this.name
  rds_instance      = length(aws_db_instance.this) != 0 ? aws_db_instance.this[0].id : aws_rds_cluster.this[0].id
}

#####################################
# AWS ALB - Response Time Gauge/Meter
#####################################
module "grafana_alb_response_time_bargauge" {
  source        = "git::https://github.com/synapsestudios/terraform-grafana-panel-bar-gauge.git?ref=release/v1.0.0"
  title         = "Response Time"
  id            = 0
  min           = 0
  max           = 1.5
  unit          = "s"
  grid_position = { h = 5, w = 12, x = 0, y = 0 }
  description   = "Overall Application Response Time"
  interval      = "1m"

  queries = [{
    refId      = "A"
    region     = local.region
    namespace  = "AWS/ApplicationELB"
    dimensions = { LoadBalancer = local.loadbalancer_name }
    metricName = "TargetResponseTime"
    alias      = "Average Response Time"
    statistics = ["Average"]
    period     = "$__interval"
    },
    {
      refId      = "B",
      region     = local.region,
      namespace  = "AWS/ApplicationELB",
      dimensions = { LoadBalancer = local.loadbalancer_name }
      metricName = "TargetResponseTime",
      alias      = "Max Response Time"
      statistics = ["Maximum"]
      period     = "$__interval"
  }]
  thresholds = {
    mode = "absolute"
    steps = [
      { color = "green", value = null },
      { color = "yellow", value = 0.5 },
      { value = 1, color = "red" }
    ]
  }
}

###################################################
# AWS ALB Grafana - RequestCount/TargetResponseTime
###################################################
module "grafana_alb_request_response" {
  source = "git::https://github.com/synapsestudios/terraform-grafana-panel-graph.git?ref=release/v1.0.0"

  title            = "ALB ${local.name} RequestCount / TargetResponseTime"
  series_overrides = [{ alias = "Response Time", yaxis = 2 }]
  null_point_mode  = "connected"
  description      = "Application Load Balancer request counts, and target response times."
  interval         = "1m"

  queries = [
    {
      refId      = "A"
      region     = local.region
      namespace  = "AWS/ApplicationELB"
      metricName = "RequestCount"
      statistics = ["Sum"]
      dimensions = { LoadBalancer = local.loadbalancer_name }
      period     = "$__interval"
      alias      = "Request Count"
    },
    {
      refId      = "B"
      region     = local.region
      namespace  = "AWS/ApplicationELB"
      metricName = "TargetResponseTime"
      statistics = ["Average"]
      dimensions = { LoadBalancer = local.loadbalancer_name }
      period     = "$__interval"
      alias      = "Response Time"
    }
  ]

  yaxes = [
    { show = true, decimals = null, format = "short", label = null, logBase = 1, min = 0, max = null },
    { show = true, decimals = null, format = "s", label = null, logBase = 1, min = 0, max = null }
  ]

  legend = { show = true, alignAsTable = false, avg = true, current = true, max = true, min = true, sort = null, sortDesc = false, total = false, values = true }
}

####################################
# AWS ALB Grafana - HTTP Code Target
####################################
module "grafana_alb_http_target_response_code" {
  source = "git::https://github.com/synapsestudios/terraform-grafana-panel-graph.git?ref=release/v1.0.0"

  title           = "ALB ${local.name} Target Response Code"
  null_point_mode = "null"
  description     = "Application Load Balancer target response codes."
  lines           = false
  bars            = true
  interval        = "1m"

  queries = [
    {
      refId      = "A"
      region     = local.region
      namespace  = "AWS/ApplicationELB"
      dimensions = { LoadBalancer = local.loadbalancer_name }
      metricName = "HTTPCode_Target_2XX_Count"
      statistics = ["Sum"]
      period     = "$bar_graph_interval"
      alias      = "2XX"
    },
    {
      refId      = "B"
      region     = local.region
      namespace  = "AWS/ApplicationELB"
      dimensions = { LoadBalancer = local.loadbalancer_name }
      metricName = "HTTPCode_Target_3XX_Count"
      statistics = ["Sum"]
      period     = "$bar_graph_interval"
      alias      = "3XX"
    },
    {
      refId      = "C"
      region     = local.region
      namespace  = "AWS/ApplicationELB"
      dimensions = { LoadBalancer = local.loadbalancer_name }
      metricName = "HTTPCode_Target_4XX_Count"
      statistics = ["Sum"]
      period     = "$bar_graph_interval"
      alias      = "4XX"
    },
    {
      refId      = "D",
      region     = local.region,
      namespace  = "AWS/ApplicationELB"
      dimensions = { LoadBalancer = local.loadbalancer_name }
      metricName = "HTTPCode_Target_5XX_Count"
      statistics = ["Sum"]
      period     = "$bar_graph_interval"
      alias      = "5XX"
    }
  ]

  yaxes = [
    { show = true, decimals = null, format = "short", label = null, logBase = 1, min = 0, max = null },
    { show = true, decimals = null, format = "short", label = null, logBase = 1, min = 0, max = null }
  ]

  legend       = { show = true, alignAsTable = false, avg = false, current = false, max = false, min = false, sort = null, sortDesc = false, total = true, values = true }
  alias_colors = { "2XX" = "dark-green", "3XX" = "dark-blue", "4XX" = "dark-yellow", "5XX" = "dark-red" }
}

#################################
# AWS ALB Grafana - HTTP Code ELB
#################################
module "grafana_alb_http_response_code" {
  source = "git::https://github.com/synapsestudios/terraform-grafana-panel-graph.git?ref=release/v1.0.0"

  title           = "ALB ${local.name} HTTP Response Code"
  null_point_mode = "null"
  description     = "Application Load Balancer response codes."
  lines           = false
  bars            = true
  interval        = "1m"

  queries = [
    {
      refId      = "A"
      region     = local.region
      namespace  = "AWS/ApplicationELB"
      dimensions = { LoadBalancer = local.loadbalancer_name }
      metricName = "HTTPCode_ELB_3XX_Count"
      statistics = ["Sum"]
      period     = "$bar_graph_interval"
      alias      = "3XX"
    },
    {
      refId      = "B"
      region     = local.region,
      namespace  = "AWS/ApplicationELB"
      dimensions = { LoadBalancer = local.loadbalancer_name }
      metricName = "HTTPCode_ELB_4XX_Count"
      statistics = ["Sum"]
      period     = "$bar_graph_interval"
      alias      = "4XX"
    },
    {
      refId      = "C"
      region     = local.region
      namespace  = "AWS/ApplicationELB"
      dimensions = { LoadBalancer = local.loadbalancer_name }
      metricName = "HTTPCode_ELB_5XX_Count"
      statistics = ["Sum"]
      period     = "$bar_graph_interval"
      alias      = "5XX"
    }
  ]

  yaxes = [
    { show = true, decimals = null, format = "short", label = null, logBase = 1, min = 0, max = null },
    { show = true, decimals = null, format = "short", label = null, logBase = 1, min = 0, max = null }
  ]

  legend       = { show = true, alignAsTable = false, avg = false, current = false, max = false, min = false, sort = null, sortDesc = false, total = true, values = true }
  alias_colors = { "3XX" = "dark-blue", "4XX" = "dark-yellow", "5XX" = "dark-red" }
}

####################################
# AWS ALB Grafana - Connection Count
####################################
module "grafana_alb_connection_count" {
  source = "git::https://github.com/synapsestudios/terraform-grafana-panel-graph.git?ref=release/v1.0.0"

  title           = "ALB ${local.name} Connection Count"
  grid_position   = { h = 5, w = 12, x = 0, y = 10 }
  id              = 5
  null_point_mode = "connected"
  description     = "Application Load Balancer connection counts."
  interval        = "1m"

  queries = [
    {
      refId      = "A"
      region     = local.region
      namespace  = "AWS/ApplicationELB"
      dimensions = { LoadBalancer = local.loadbalancer_name }
      metricName = "TargetConnectionErrorCount"
      statistics = ["Average"]
      period     = "$__interval"
    },
    {
      refId      = "B"
      region     = local.region
      namespace  = "AWS/ApplicationELB"
      dimensions = { LoadBalancer = local.loadbalancer_name }
      metricName = "RejectedConnectionCount"
      statistics = ["Average"]
      period     = "$__interval"
    },
    {
      refId      = "C"
      region     = local.region
      namespace  = "AWS/ApplicationELB"
      dimensions = { LoadBalancer = local.loadbalancer_name }
      metricName = "NewConnectionCount"
      statistics = ["Average"]
      period     = "$__interval"
    },
    {
      refId      = "D"
      region     = local.region
      namespace  = "AWS/ApplicationELB"
      dimensions = { LoadBalancer = local.loadbalancer_name }
      metricName = "ActiveConnectionCount"
      statistics = ["Average"]
      period     = "$__interval"
    }
  ]

  yaxes = [
    { show = true, decimals = null, format = "none", label = null, logBase = 1, min = 0, max = null },
    { show = true, decimals = null, format = "short", label = null, logBase = 1, min = 0, max = null }
  ]
}

##################################
# RDS OS Grafana - CPU Utilization
##################################
module "grafana_rds_cpu_utilization" {
  source = "git::https://github.com/synapsestudios/terraform-grafana-panel-graph.git?ref=release/v1.0.0"

  title           = "RDS ${var.namespace} CPU Utilization"
  null_point_mode = "connected"
  description     = "RDS CPU Utilization."
  interval        = "1m"

  queries = [
    {
      refId      = "A"
      region     = local.region
      namespace  = "AWS/RDS"
      metricName = "CPUUtilization"
      statistics = ["Average"]
      dimensions = { DBInstanceIdentifier = local.rds_instance }
      period     = "$__interval"
    }
  ]

  yaxes = [
    { show = true, decimals = null, format = "none", label = null, logBase = 1, min = 0, max = null },
    { show = true, decimals = null, format = "short", label = null, logBase = 1, min = 0, max = null }
  ]
}

###################################
# RDS OS Grafana - CPU Credit Usage
###################################
module "grafana_rds_cpu_credit" {
  source = "git::https://github.com/synapsestudios/terraform-grafana-panel-graph.git?ref=release/v1.0.0"

  title           = "RDS ${var.namespace} CPU Credit Usage"
  null_point_mode = "connected"
  description     = "RDS CPU credits accumulated and consumed."
  interval        = "5m"

  queries = [
    {
      refId      = "A"
      region     = local.region
      namespace  = "AWS/RDS"
      metricName = "CPUCreditBalance"
      statistics = ["Average"]
      dimensions = { DBInstanceIdentifier = local.rds_instance }
      alias      = "Credits Accumulated"
      period     = "$__interval"
    },
    {
      refId      = "B"
      region     = local.region
      namespace  = "AWS/RDS"
      metricName = "CPUCreditUsage"
      statistics = ["Average"]
      dimensions = { DBInstanceIdentifier = local.rds_instance }
      alias      = "Credits Consumed"
      period     = "$__interval"
    }
  ]

  yaxes = [
    { show = true, decimals = null, format = "short", label = null, logBase = 1, min = 0, max = null },
    { show = true, decimals = null, format = "short", label = null, logBase = 1, min = null, max = null }
  ]
}

###################################
# RDS OS Grafana - Available Memory
###################################
module "grafana_rds_available_memory" {
  source = "git::https://github.com/synapsestudios/terraform-grafana-panel-graph.git?ref=release/v1.0.0"

  title           = "RDS ${var.namespace} Available Memory"
  null_point_mode = "connected"
  description     = "RDS freeable memory."
  interval        = "1m"

  queries = [
    {
      refId      = "A"
      region     = local.region
      namespace  = "AWS/RDS"
      metricName = "FreeableMemory"
      statistics = ["Average"]
      dimensions = { DBInstanceIdentifier = local.rds_instance }
      alias      = "Available"
      period     = "$__interval"
    }
  ]

  yaxes = [
    { show = true, decimals = null, format = "bytes", label = null, logBase = 1, min = 0, max = null },
    { show = true, decimals = null, format = "short", label = null, logBase = 1, min = null, max = null }
  ]
}

#############################
# RDS OS Grafana - Swap Usage
#############################
module "grafana_rds_swap_usage" {
  source = "git::https://github.com/synapsestudios/terraform-grafana-panel-graph.git?ref=release/v1.0.0"

  title           = "RDS ${var.namespace} Swap Usage"
  null_point_mode = "connected"
  description     = "RDS swap utilization."
  interval        = "1m"

  queries = [
    {
      refId      = "A"
      region     = local.region
      namespace  = "AWS/RDS"
      metricName = "SwapUsage"
      statistics = ["Average"]
      dimensions = { DBInstanceIdentifier = local.rds_instance }
      alias      = "Used"
      period     = "$__interval"
    }
  ]

  yaxes = [
    { show = true, decimals = null, format = "bytes", label = null, logBase = 1, min = 0, max = null },
    { show = true, decimals = null, format = "short", label = null, logBase = 1, min = null, max = null }
  ]
}

################################
# RDS OS Grafana - Storage Space
################################
module "grafana_rds_storage_space" {
  source = "git::https://github.com/synapsestudios/terraform-grafana-panel-graph.git?ref=release/v1.0.0"

  title           = "RDS ${var.namespace} Storage Space"
  null_point_mode = "connected"
  interval        = "1m"

  queries = [
    {
      refId      = "A"
      region     = local.region
      namespace  = "AWS/RDS"
      metricName = "FreeStorageSpace"
      statistics = ["Average"]
      dimensions = { DBInstanceIdentifier = local.rds_instance }
      alias      = "Available"
      period     = "$__interval"
    }
  ]

  yaxes = [
    { show = true, decimals = null, format = "bytes", label = null, logBase = 1, min = 0, max = null },
    { show = true, decimals = null, format = "short", label = null, logBase = 1, min = null, max = null }
  ]
}

############################
# RDS OS Grafana - Disk IOPS
############################
module "grafana_rds_disk_iops" {
  source = "git::https://github.com/synapsestudios/terraform-grafana-panel-graph.git?ref=release/v1.0.0"

  title           = "RDS ${var.namespace} Disk IOPS"
  null_point_mode = "connected"
  interval        = "5m"

  queries = [
    {
      refId      = "A"
      region     = local.region
      namespace  = "AWS/RDS"
      metricName = "ReadIOPS"
      statistics = ["Average"]
      dimensions = { DBInstanceIdentifier = local.rds_instance }
      alias      = "Read"
      period     = "$__interval"
    },
    {
      refId      = "B"
      region     = local.region
      namespace  = "AWS/RDS"
      metricName = "WriteIOPS"
      statistics = ["Average"]
      dimensions = { DBInstanceIdentifier = local.rds_instance }
      alias      = "Write"
      period     = "$__interval"
    }
  ]

  yaxes = [
    { show = true, decimals = null, format = "iops", label = null, logBase = 1, min = 0, max = null },
    { show = true, decimals = null, format = "short", label = null, logBase = 1, min = null, max = null }
  ]
}

###############################
# RDS OS Grafana - Disk Latency
###############################
module "grafana_rds_disk_latency" {
  source = "git::https://github.com/synapsestudios/terraform-grafana-panel-graph.git?ref=release/v1.0.0"

  title           = "RDS ${var.namespace} Disk Latency"
  null_point_mode = "connected"
  interval        = "5m"

  queries = [
    {
      refId      = "A"
      region     = local.region
      namespace  = "AWS/RDS"
      metricName = "ReadLatency"
      statistics = ["Average"]
      dimensions = { DBInstanceIdentifier = local.rds_instance }
      alias      = "Read"
      period     = "$__interval"
    },
    {
      refId      = "B"
      region     = local.region
      namespace  = "AWS/RDS"
      metricName = "WriteLatency"
      statistics = ["Average"]
      dimensions = { DBInstanceIdentifier = local.rds_instance }
      alias      = "Write"
      period     = "$__interval"
    }
  ]

  yaxes = [
    { show = true, decimals = null, format = "s", label = null, logBase = 1, min = 0, max = null },
    { show = true, decimals = null, format = "short", label = null, logBase = 1, min = null, max = null }
  ]
}

###################################
# RDS OS Grafana - Disk Queue Depth
###################################
module "grafana_rds_disk_queue_depth" {
  source = "git::https://github.com/synapsestudios/terraform-grafana-panel-graph.git?ref=release/v1.0.0"

  title           = "RDS ${var.namespace} Disk Queue Depth"
  null_point_mode = "null"
  interval        = "5m"

  queries = [
    {
      refId      = "A"
      region     = local.region
      namespace  = "AWS/RDS"
      metricName = "DiskQueueDepth"
      statistics = ["Average"]
      dimensions = { DBInstanceIdentifier = local.rds_instance }
      alias      = "Outstanding IO Requests"
      period     = "$__interval"
    }
  ]

  yaxes = [
    { show = true, decimals = 0, format = "short", label = null, logBase = 1, min = 0, max = null },
    { show = true, decimals = null, format = "short", label = null, logBase = 1, min = null, max = null }
  ]
}

##################################
# RDS OS Grafana - Disk Throughput
##################################
module "grafana_rds_disk_throughput" {
  source = "git::https://github.com/synapsestudios/terraform-grafana-panel-graph.git?ref=release/v1.0.0"

  title           = "RDS ${var.namespace} Disk Throughput"
  null_point_mode = "null"
  interval        = "5m"

  queries = [
    {
      refId      = "A"
      region     = local.region
      namespace  = "AWS/RDS"
      metricName = "ReadThroughput"
      statistics = ["Average"]
      dimensions = { DBInstanceIdentifier = local.rds_instance }
      alias      = "Read"
      period     = "$__interval"
    },
    {
      refId      = "B"
      region     = local.region
      namespace  = "AWS/RDS"
      metricName = "WriteThroughput"
      statistics = ["Average"]
      dimensions = { DBInstanceIdentifier = local.rds_instance }
      alias      = "Write"
      period     = "$__interval"
    }
  ]

  yaxes = [
    { show = true, decimals = null, format = "Bps", label = null, logBase = 1, min = 0, max = null },
    { show = true, decimals = null, format = "short", label = null, logBase = 1, min = null, max = null }
  ]
}

##################################
# RDS OS Grafana - Network Traffic
##################################
module "grafana_rds_network_traffic" {
  source = "git::https://github.com/synapsestudios/terraform-grafana-panel-graph.git?ref=release/v1.0.0"

  title           = "RDS ${var.namespace} Network Traffic"
  null_point_mode = "null"
  description     = "Total number of bytes in/out from the instance's network interfaces."
  interval        = "5m"

  queries = [
    {
      refId      = "A"
      region     = local.region
      namespace  = "AWS/RDS"
      metricName = "NetworkReceiveThroughput"
      statistics = ["Average"]
      dimensions = { DBInstanceIdentifier = local.rds_instance }
      alias      = "Inbound"
      period     = "$__interval"
    },
    {
      refId      = "B"
      region     = local.region
      namespace  = "AWS/RDS"
      metricName = "NetworkTransmitThroughput"
      statistics = ["Average"]
      dimensions = { DBInstanceIdentifier = local.rds_instance }
      alias      = "Outbound"
      period     = "$__interval"
    }
  ]

  yaxes = [
    { show = true, decimals = null, format = "Bps", label = null, logBase = 1, min = 0, max = null },
    { show = true, decimals = null, format = "short", label = null, logBase = 1, min = null, max = null }
  ]
}

#######################
# Redis Grafana - Cache
#######################
module "grafana_redis_cache" {
  source = "git::https://github.com/synapsestudios/terraform-grafana-panel-graph.git?ref=release/v1.0.0"

  title           = "Redis ${var.namespace} Cache"
  null_point_mode = "null"
  description     = "Hits: The number of successful read-only key lookups in the main dictionary. Misses: The number of unsuccessful read-only key lookups in the main dictionary. Evictions: The number of keys that have been evicted due to the maxmemory limit. Reclaimed: The total number of key expiration events."
  interval        = "1m"


  queries = [
    {
      refId      = "A"
      region     = local.region
      namespace  = "AWS/ElastiCache"
      metricName = "CacheHits"
      statistics = ["Average"]
      dimensions = { CacheClusterId = local.redis_cluster_id }
      alias      = "{{CacheClusterId}} Hits"
      period     = "$__interval"
    },
    {
      refId      = "B"
      region     = local.region
      namespace  = "AWS/ElastiCache"
      metricName = "CacheMisses"
      statistics = ["Average"]
      dimensions = { CacheClusterId = local.redis_cluster_id }
      alias      = "{{CacheClusterId}} Misses"
      period     = "$__interval"
    },
    {
      refId      = "C"
      region     = local.region
      namespace  = "AWS/ElastiCache"
      metricName = "Evictions"
      statistics = ["Average"]
      dimensions = { CacheClusterId = local.redis_cluster_id }
      alias      = "{{CacheClusterId}} Evictions"
      period     = "$__interval"
    },
    {
      refId      = "D"
      region     = local.region
      namespace  = "AWS/ElastiCache"
      metricName = "Reclaimed"
      statistics = ["Average"]
      dimensions = { CacheClusterId = local.redis_cluster_id }
      alias      = "{{CacheClusterId}} Reclaimed"
      period     = "$__interval"
    }
  ]

  yaxes = [
    { show = true, decimals = null, format = "none", label = null, logBase = 1, min = 0, max = null },
    { show = true, decimals = null, format = "none", label = null, logBase = 1, min = 0, max = null }
  ]
}

##########################
# Redis Grafana - Commands
##########################
module "grafana_redis_commands" {
  source = "git::https://github.com/synapsestudios/terraform-grafana-panel-graph.git?ref=release/v1.0.0"

  title           = "Redis ${var.namespace} Commands"
  null_point_mode = "null"
  description     = "Total number of Redis commands by type/category."
  interval        = "1m"

  queries = [
    {
      refId      = "A"
      region     = local.region
      namespace  = "AWS/ElastiCache"
      metricName = "GetTypeCmds"
      statistics = ["Average"]
      dimensions = { CacheClusterId = local.redis_cluster_id }
      alias      = "{{CacheClusterId}} GetType Commands"
      period     = "$__interval"
    },
    {
      refId      = "B"
      region     = local.region
      namespace  = "AWS/ElastiCache"
      metricName = "HashBasedCmds"
      statistics = ["Average"]
      dimensions = { CacheClusterId = local.redis_cluster_id }
      alias      = "{{CacheClusterId}} HashBased Commands"
      period     = "$__interval"
    },
    {
      refId      = "C"
      region     = local.region
      namespace  = "AWS/ElastiCache"
      metricName = "ListBasedCmds"
      statistics = ["Average"]
      dimensions = { CacheClusterId = local.redis_cluster_id }
      alias      = "{{CacheClusterId}} ListBased Commands"
      period     = "$__interval"
    },
    {
      refId      = "D"
      region     = local.region
      namespace  = "AWS/ElastiCache"
      metricName = "SetBasedCmds"
      statistics = ["Average"]
      dimensions = { CacheClusterId = local.redis_cluster_id }
      alias      = "{{CacheClusterId}} SetBased Commands"
      period     = "$__interval"
    },
    {
      refId      = "E"
      region     = local.region
      namespace  = "AWS/ElastiCache"
      metricName = "SetTypeCmds"
      statistics = ["Average"]
      dimensions = { CacheClusterId = local.redis_cluster_id }
      alias      = "{{CacheClusterId}} SetType Commands"
      period     = "$__interval"
    },
    {
      refId      = "F"
      region     = local.region
      namespace  = "AWS/ElastiCache"
      metricName = "SortedSetBasedCmds"
      statistics = ["Average"]
      dimensions = { CacheClusterId = local.redis_cluster_id }
      alias      = "{{CacheClusterId}} SortedSet Commands"
      period     = "$__interval"
    },
    {
      refId      = "G"
      region     = local.region
      namespace  = "AWS/ElastiCache"
      metricName = "StringBasedCmds"
      statistics = ["Average"]
      dimensions = { CacheClusterId = local.redis_cluster_id }
      alias      = "{{CacheClusterId}} String Commands"
      period     = "$__interval"
    }
  ]

  yaxes = [
    { show = true, decimals = null, format = "none", label = null, logBase = 1, min = 0, max = null },
    { show = false, decimals = null, format = "none", label = null, logBase = 1, min = 0, max = null }
  ]
}

#############################
# Redis Grafana - Connections
#############################
module "grafana_redis_connections" {
  source = "git::https://github.com/synapsestudios/terraform-grafana-panel-graph.git?ref=release/v1.0.0"

  title           = "Redis ${var.namespace} Connections"
  null_point_mode = "null"
  description     = "The number of client connections, excluding connections from read replicas. ElastiCache uses two to four of the connections to monitor the cluster in each case."
  interval        = "1m"

  queries = [
    {
      refId      = "A"
      region     = local.region
      namespace  = "AWS/ElastiCache"
      metricName = "NewConnections"
      statistics = ["Average"]
      dimensions = { CacheClusterId = local.redis_cluster_id }
      alias      = "{{CacheClusterId}} New Connections"
      period     = "$__interval"
    },
    {
      refId      = "B"
      region     = local.region
      namespace  = "AWS/ElastiCache"
      metricName = "CurrConnections"
      statistics = ["Average"]
      dimensions = { CacheClusterId = local.redis_cluster_id }
      alias      = "{{CacheClusterId}} Current Connections"
      period     = "$__interval"
    }
  ]

  yaxes = [
    { show = true, decimals = null, format = "none", label = null, logBase = 1, min = 0, max = null },
    { show = true, decimals = null, format = "none", label = null, logBase = 1, min = 0, max = null }
  ]
}

##################################################
# Redis Grafana - Save In Progeess / Current Items
##################################################
module "grafana_redis_items" {
  source = "git::https://github.com/synapsestudios/terraform-grafana-panel-graph.git?ref=release/v1.0.0"

  title            = "Redis ${var.namespace} Save In Progeess / Current Items"
  series_overrides = [for id in local.redis_cluster_id : { alias = "${id} Current Items", yaxis = 2 }]
  null_point_mode  = "null"
  description      = "Save In Progress: This binary metric returns 1 whenever a background save (forked or forkless) is in progress, and 0 otherwise. A background save process is typically used during snapshots and syncs. These operations can cause degraded performance. Using the SaveInProgress metric, you can diagnose whether or not degraded performance was caused by a background save process. Current Items: The number of items in the cache. This is derived from the Redis keyspace statistic, summing all of the keys in the entire keyspace."
  interval         = "1m"

  queries = [
    {
      refId      = "A"
      region     = local.region
      namespace  = "AWS/ElastiCache"
      metricName = "SaveInProgress"
      statistics = ["Average"]
      dimensions = { CacheClusterId = local.redis_cluster_id }
      alias      = "{{CacheClusterId}} Save In Progress"
      period     = "$__interval"
    },
    {
      refId      = "B"
      region     = local.region
      namespace  = "AWS/ElastiCache"
      metricName = "CurrItems"
      statistics = ["Average"]
      dimensions = { CacheClusterId = local.redis_cluster_id }
      alias      = "{{CacheClusterId}} Current Items"
      period     = "$__interval"
    }
  ]

  yaxes = [
    { show = true, decimals = 0, format = "none", label = null, logBase = 1, min = 0, max = null },
    { show = true, decimals = null, format = "none", label = null, logBase = 1, min = 0, max = null }
  ]
}

###################################################################
# Redis Grafana - Bytes Used For Cache / Bytes Used For Replication
###################################################################
module "grafana_redis_bytes_used_for_cache_and_replication" {
  source = "git::https://github.com/synapsestudios/terraform-grafana-panel-graph.git?ref=release/v1.0.0"

  title            = "Redis ${var.namespace} Bytes Used For Cache / Bytes Used For Replication"
  series_overrides = [for id in local.redis_cluster_id : { alias = "${id} Bytes Used For Replication", yaxis = 2 }]
  null_point_mode  = "null"
  description      = "Bytes Used For Cache: The total number of bytes allocated by Redis for all purposes, including the dataset, buffers, etc. Bytes Used For Replication: For nodes in a replicated configuration, ReplicationBytes reports the number of bytes that the primary is sending to all of its replicas."
  interval         = "1m"

  queries = [
    {
      refId      = "A"
      region     = local.region
      namespace  = "AWS/ElastiCache"
      metricName = "BytesUsedForCache"
      statistics = ["Average"]
      dimensions = { CacheClusterId = local.redis_cluster_id }
      alias      = "{{CacheClusterId}} Bytes Used For Cache"
      period     = "$__interval"
    },
    {
      refId      = "B"
      region     = local.region
      namespace  = "AWS/ElastiCache"
      metricName = "ReplicationBytes"
      statistics = ["Average"]
      dimensions = { CacheClusterId = local.redis_cluster_id }
      alias      = "{{CacheClusterId}} Bytes Used For Replication"
      period     = "$__interval"
    }
  ]

  yaxes = [
    { show = true, decimals = null, format = "bytes", label = null, logBase = 1, min = 0, max = null },
    { show = true, decimals = null, format = "bytes", label = null, logBase = 1, min = 0, max = null }
  ]
}

############################################
# Redis Grafana - HyperLog / Replication Lag
############################################
module "grafana_redis_hyperlog_replication_lag" {
  source = "git::https://github.com/synapsestudios/terraform-grafana-panel-graph.git?ref=release/v1.0.0"

  title            = "Redis ${var.namespace} HyperLog / Replication Lag"
  series_overrides = [for id in local.redis_cluster_id : { alias = "${id} Replication Lag", yaxis = 2 }]
  null_point_mode  = "null"
  description      = "HyperLog Commands: The total number of HyperLogLog-based commands, (pfadd, pfcount, pfmerge, etc.). Replication Lag: This metric is only applicable for a node running as a read replica. It represents how far behind, in seconds, the replica is in applying changes from the primary node."
  interval         = "1m"

  queries = [
    {
      refId      = "A"
      region     = local.region
      namespace  = "AWS/ElastiCache"
      metricName = "HyperLogLogBasedCmds"
      statistics = ["Average"]
      dimensions = { CacheClusterId = local.redis_cluster_id }
      alias      = "HyperLog Commands"
      period     = "$__interval"
    },
    {
      refId      = "B"
      region     = local.region
      namespace  = "AWS/ElastiCache"
      metricName = "ReplicationLag"
      statistics = ["Average"]
      dimensions = { CacheClusterId = local.redis_cluster_id }
      alias      = "{{CacheClusterId}} Replication Lag"
      period     = "$__interval"
    }
  ]

  yaxes = [
    { show = true, decimals = 0, format = "none", label = null, logBase = 1, min = 0, max = null },
    { show = true, decimals = null, format = "s", label = null, logBase = 1, min = 0, max = null }
  ]

  legend = { show = true, alignAsTable = false, avg = false, current = false, max = true, min = false, sort = null, sortDesc = false, total = false, values = false }
}

#################################
# Redis Grafana - CPU Utilization
#################################
module "grafana_redis_cpu_utilization" {
  source = "git::https://github.com/synapsestudios/terraform-grafana-panel-graph.git?ref=release/v1.0.0"

  title            = "Redis ${var.namespace} CPU Utilization"
  series_overrides = [for id in local.redis_cluster_id : { alias = "${id} Engine CPU Utlization", yaxis = 2 }]
  null_point_mode  = "null"
  description      = "The percentage of CPU utilization for the entire host. Because Redis is single-threaded, we recommend you monitor EngineCPUUtilization metric for nodes with 4 or more vCPUs."
  interval         = "1m"

  queries = [
    {
      refId      = "A"
      region     = local.region
      namespace  = "AWS/ElastiCache"
      metricName = "CPUUtilization"
      statistics = ["Average"]
      dimensions = { CacheClusterId = local.redis_cluster_id }
      alias      = "{{CacheClusterId}} CPU Utlization"
      period     = "$__interval"
    },
    {
      refId      = "B"
      region     = local.region
      namespace  = "AWS/ElastiCache"
      metricName = "EngineCPUUtilization"
      statistics = ["Average"]
      dimensions = { CacheClusterId = local.redis_cluster_id }
      alias      = "{{CacheClusterId}} Engine CPU Utlization"
      period     = "$__interval"
    }
  ]

  yaxes = [
    { show = true, decimals = null, format = "percent", label = null, logBase = 1, min = 0, max = null },
    { show = false, decimals = null, format = "none", label = null, logBase = 1, min = 0, max = null }
  ]
}

#################################
# Redis Grafana - Network Traffic
#################################
module "grafana_redis_network_traffic" {
  source = "git::https://github.com/synapsestudios/terraform-grafana-panel-graph.git?ref=release/v1.0.0"

  title            = "Redis ${var.namespace} Network Traffic"
  series_overrides = [for id in local.redis_cluster_id : { alias = "${id} Inbound", yaxis = 2 }]
  null_point_mode  = "null"
  description      = "Total number of bytes in and out from the instance's network interfaces."
  interval         = "1m"

  queries = [
    {
      refId      = "A"
      region     = local.region
      namespace  = "AWS/ElastiCache"
      metricName = "NetworkBytesIn"
      statistics = ["Average"]
      dimensions = { CacheClusterId = local.redis_cluster_id }
      alias      = "{{CacheClusterId}} Inbound"
      period     = "$__interval"
    },
    {
      refId      = "B"
      region     = local.region
      namespace  = "AWS/ElastiCache"
      metricName = "NetworkBytesOut"
      statistics = ["Average"]
      dimensions = { CacheClusterId = local.redis_cluster_id }
      alias      = "{{CacheClusterId}} Outbound"
      period     = "$__interval"
    }
  ]

  yaxes = [
    { show = true, decimals = null, format = "bytes", label = null, logBase = 1, min = 0, max = null },
    { show = true, decimals = null, format = "bytes", label = null, logBase = 1, min = 0, max = null }
  ]
}

###############################
# Redis Grafana - Memory / Swap
###############################
module "grafana_redis_memory_and_swap" {
  source = "git::https://github.com/synapsestudios/terraform-grafana-panel-graph.git?ref=release/v1.0.0"

  title            = "Redis ${var.namespace} Freeable Memory / Swap Usage"
  series_overrides = [for id in local.redis_cluster_id : { alias = "${id} Freeable Memory", yaxis = 2 }]
  null_point_mode  = "null"
  description      = "The amount of free memory available on the host. This is derived from the RAM, buffers and cache that the OS reports as freeable. Additionally the amount of swap used on the host."
  interval         = "1m"

  queries = [
    {
      refId      = "A"
      region     = local.region
      namespace  = "AWS/ElastiCache"
      metricName = "SwapUsage"
      statistics = ["Average"]
      dimensions = { CacheClusterId = local.redis_cluster_id }
      alias      = "{{CacheClusterId}} Swap Used"
      period     = "$__interval"
    },
    {
      refId      = "B"
      region     = local.region
      namespace  = "AWS/ElastiCache"
      metricName = "FreeableMemory"
      statistics = ["Average"]
      dimensions = { CacheClusterId = local.redis_cluster_id }
      alias      = "{{CacheClusterId}} Freeable Memory"
      period     = "$__interval"
    }
  ]

  yaxes = [
    { show = true, decimals = null, format = "bytes", label = null, logBase = 1, min = 0, max = null },
    { show = true, decimals = null, format = "bytes", label = null, logBase = 1, min = 0, max = null }
  ]
}

########################################
# ElasticSearch Grafana - Cluster Status
########################################
module "grafana_es_cluster_status" {
  source = "git::https://github.com/synapsestudios/terraform-grafana-panel-graph.git?ref=release/v1.0.0"

  title           = "ElasticSearch ${var.namespace} Cluster Status"
  null_point_mode = "null"
  description     = "Indicates shard allocation status."
  interval        = "1m"

  queries = [
    {
      refId      = "A"
      region     = local.region
      namespace  = "AWS/ES"
      metricName = "ClusterStatus.green"
      statistics = ["Maximum"]
      dimensions = { ClientId = data.aws_caller_identity.current.account_id, DomainName = aws_elasticsearch_domain.this[0].domain_name }
      alias      = "Green"
      period     = "$__interval"
    },
    {
      refId      = "B"
      region     = local.region
      namespace  = "AWS/ES"
      metricName = "ClusterStatus.yellow"
      statistics = ["Maximum"]
      dimensions = { ClientId = data.aws_caller_identity.current.account_id, DomainName = aws_elasticsearch_domain.this[0].domain_name }
      alias      = "Yellow"
      period     = "$__interval"
    },
    {
      refId      = "C"
      region     = local.region
      namespace  = "AWS/ES"
      metricName = "ClusterStatus.red"
      statistics = ["Maximum"]
      dimensions = { ClientId = data.aws_caller_identity.current.account_id, DomainName = aws_elasticsearch_domain.this[0].domain_name }
      alias      = "Red"
      period     = "$__interval"
    }
  ]

  legend = { show = true, alignAsTable = false, avg = false, current = false, max = false, min = false, sort = null, sortDesc = false, total = false, values = false }

  alias_colors = { Green = "dark-green", Red = "dark-red", Yellow = "dark-yellow" }

  yaxes = [
    { show = true, decimals = 0, format = "short", label = null, logBase = 1, min = 0, max = null },
    { show = true, decimals = 0, format = "short", label = null, logBase = 1, min = 0, max = null }
  ]
}

#####################################
# ElasticSearch Grafana - Total Nodes
#####################################
module "grafana_es_total_nodes" {
  source = "git::https://github.com/synapsestudios/terraform-grafana-panel-graph.git?ref=release/v1.0.0"

  title           = "ElasticSearch ${var.namespace} Total Nodes"
  null_point_mode = "null"
  description     = "The total number of nodes for your cluster. This metric can increase (often doubling) during configuration changes and service software updates."
  interval        = "1m"

  queries = [
    {
      refId      = "A"
      region     = local.region
      namespace  = "AWS/ES"
      metricName = "Nodes"
      statistics = ["Minimum"]
      dimensions = { ClientId = data.aws_caller_identity.current.account_id, DomainName = aws_elasticsearch_domain.this[0].domain_name }
      alias      = "Nodes"
      period     = "$__interval"
    }
  ]

  legend = { show = true, alignAsTable = false, avg = false, current = false, max = false, min = false, sort = null, sortDesc = false, total = false, values = false }

  yaxes = [
    { show = true, decimals = 0, format = "short", label = null, logBase = 1, min = 0, max = null },
    { show = true, decimals = 0, format = "short", label = null, logBase = 1, min = 0, max = null }
  ]
}

####################################################
# ElasticSearch Grafana - CPU Utilization Data Nodes
####################################################
module "grafana_es_cpu_utilization_data_nodes" {
  source = "git::https://github.com/synapsestudios/terraform-grafana-panel-graph.git?ref=release/v1.0.0"

  title           = "ElasticSearch ${var.namespace} CPU Utilization On All Data Nodes"
  null_point_mode = "null"
  description     = "Maximum CPU utilization percentage for all data nodes."
  interval        = "1m"

  queries = [
    {
      refId      = "A"
      region     = local.region
      namespace  = "AWS/ES"
      metricName = "CPUUtilization"
      statistics = ["Average"]
      dimensions = { ClientId = data.aws_caller_identity.current.account_id, DomainName = aws_elasticsearch_domain.this[0].domain_name }
      alias      = "CPU Utilization"
      period     = "$__interval"
    }
  ]

  legend = { show = true, alignAsTable = false, avg = true, current = true, max = true, min = true, sort = null, sortDesc = false, total = false, values = false }

  yaxes = [
    { show = true, decimals = 0, format = "percent", label = null, logBase = 1, min = 0, max = null },
    { show = true, decimals = 0, format = "short", label = null, logBase = 1, min = 0, max = null }
  ]
}

############################################
# ElasticSearch Grafana - Free Storage Space
############################################
module "grafana_es_free_storage_space" {
  source = "git::https://github.com/synapsestudios/terraform-grafana-panel-graph.git?ref=release/v1.0.0"

  title           = "ElasticSearch ${var.namespace} Free Storage Space"
  null_point_mode = "null"
  description     = "The total amount of free storage space, accross all data nodes."
  interval        = "1m"

  queries = [
    {
      refId      = "A"
      region     = local.region
      namespace  = "AWS/ES"
      metricName = "FreeStorageSpace"
      statistics = ["Sum"]
      dimensions = { ClientId = data.aws_caller_identity.current.account_id, DomainName = aws_elasticsearch_domain.this[0].domain_name }
      alias      = "Free Space"
      period     = "$__interval"
    }
  ]

  yaxes = [
    { show = true, decimals = 2, format = "decmbytes", label = null, logBase = 1, min = 0, max = null },
    { show = true, decimals = null, format = "short", label = null, logBase = 1, min = 0, max = null }
  ]
}

##############################################
# ElasticSearch Grafana - Searchable Documents
##############################################
module "grafana_es_searchable_documents" {
  source = "git::https://github.com/synapsestudios/terraform-grafana-panel-graph.git?ref=release/v1.0.0"

  title           = "ElasticSearch ${var.namespace} Searchable Documents"
  null_point_mode = "null"
  description     = "The total number of searchable documents across all indices in the cluster."
  interval        = "1m"

  queries = [
    {
      refId      = "A"
      region     = local.region
      namespace  = "AWS/ES"
      metricName = "SearchableDocuments"
      statistics = ["Average"]
      dimensions = { ClientId = data.aws_caller_identity.current.account_id, DomainName = aws_elasticsearch_domain.this[0].domain_name }
      alias      = "Searchable Documents"
      period     = "$__interval"
    }
  ]

  yaxes = [
    { show = true, decimals = null, format = "short", label = null, logBase = 1, min = 0, max = null },
    { show = true, decimals = null, format = "short", label = null, logBase = 1, min = 0, max = null }
  ]
}

###########################################
# ElasticSearch Grafana - Deleted Documents
###########################################
module "grafana_es_deleted_documents" {
  source = "git::https://github.com/synapsestudios/terraform-grafana-panel-graph.git?ref=release/v1.0.0"

  title           = "ElasticSearch ${var.namespace} Deleted Documents"
  null_point_mode = "null"
  description     = "The total number of documents marked for deletion across all indices in the cluster."
  interval        = "1m"

  queries = [
    {
      refId      = "A"
      region     = local.region
      namespace  = "AWS/ES"
      metricName = "DeletedDocuments"
      statistics = ["Average"]
      dimensions = { ClientId = data.aws_caller_identity.current.account_id, DomainName = aws_elasticsearch_domain.this[0].domain_name }
      alias      = "Deleted Documents"
      period     = "$__interval"
    }
  ]

  yaxes = [
    { show = true, decimals = null, format = "short", label = null, logBase = 1, min = 0, max = null },
    { show = true, decimals = null, format = "short", label = null, logBase = 1, min = 0, max = null }
  ]
}

#######################################
# ElasticSearch Grafana - Indexing Rate
#######################################
module "grafana_es_indexing_rate" {
  source = "git::https://github.com/synapsestudios/terraform-grafana-panel-graph.git?ref=release/v1.0.0"

  title           = "ElasticSearch ${var.namespace} Indexing Rate"
  null_point_mode = "null"
  description     = "The number of indexing operations per minute. For example, a single call to the _bulk API that adds two documents and updates two counts as four operations plus four additional operations per replica. Document deletions do not towards this metric."
  interval        = "1m"

  queries = [
    {
      refId      = "A"
      region     = local.region
      namespace  = "AWS/ES"
      metricName = "IndexingRate"
      statistics = ["Average"]
      dimensions = { ClientId = data.aws_caller_identity.current.account_id, DomainName = aws_elasticsearch_domain.this[0].domain_name }
      alias      = "Operations/Minute"
      period     = "$__interval"
    }
  ]

  yaxes = [
    { show = true, decimals = null, format = "short", label = null, logBase = 1, min = 0, max = null },
    { show = true, decimals = null, format = "short", label = null, logBase = 1, min = 0, max = null }
  ]
}

##########################################
# ElasticSearch Grafana - Indexing Latency
##########################################
module "grafana_es_indexing_latency" {
  source = "git::https://github.com/synapsestudios/terraform-grafana-panel-graph.git?ref=release/v1.0.0"

  title           = "ElasticSearch ${var.namespace} Indexing Latency"
  null_point_mode = "null"
  description     = "The average time that it takes a shard to complete an indexing operation."
  interval        = "1m"

  queries = [
    {
      refId      = "A"
      region     = local.region
      namespace  = "AWS/ES"
      metricName = "IndexingLatency"
      statistics = ["Average"]
      dimensions = { ClientId = data.aws_caller_identity.current.account_id, DomainName = aws_elasticsearch_domain.this[0].domain_name }
      alias      = "Latency"
      period     = "$__interval"
    }
  ]

  yaxes = [
    { show = true, decimals = null, format = "ms", label = null, logBase = 1, min = 0, max = null },
    { show = true, decimals = null, format = "short", label = null, logBase = 1, min = 0, max = null }
  ]
}

#####################################
# ElasticSearch Grafana - Search Rate
#####################################
module "grafana_es_search_rate" {
  source = "git::https://github.com/synapsestudios/terraform-grafana-panel-graph.git?ref=release/v1.0.0"

  title           = "ElasticSearch ${var.namespace} Search Rate"
  null_point_mode = "null"
  description     = "The number of search operations per minute for all shards in the cluster. For example, a single call to the _search API that returns results from five shards counts as five operations."
  interval        = "1m"

  queries = [
    {
      refId      = "A"
      region     = local.region
      namespace  = "AWS/ES"
      metricName = "SearchRate"
      statistics = ["Average"]
      dimensions = { ClientId = data.aws_caller_identity.current.account_id, DomainName = aws_elasticsearch_domain.this[0].domain_name }
      alias      = "Operations/Minute"
      period     = "$__interval"
    }
  ]

  yaxes = [
    { show = true, decimals = null, format = "short", label = null, logBase = 1, min = 0, max = null },
    { show = true, decimals = null, format = "short", label = null, logBase = 1, min = 0, max = null }
  ]
}

########################################
# ElasticSearch Grafana - Search Latency
########################################
module "grafana_es_search_latency" {
  source = "git::https://github.com/synapsestudios/terraform-grafana-panel-graph.git?ref=release/v1.0.0"

  title           = "ElasticSearch ${var.namespace} Search Latency"
  null_point_mode = "null"
  description     = "The average time that it takes a shard to complete a search operation."
  interval        = "1m"

  queries = [
    {
      refId      = "A"
      region     = local.region
      namespace  = "AWS/ES"
      metricName = "SearchLatency"
      statistics = ["Average"]
      dimensions = { ClientId = data.aws_caller_identity.current.account_id, DomainName = aws_elasticsearch_domain.this[0].domain_name }
      alias      = "Latency"
      period     = "$__interval"
    }
  ]

  yaxes = [
    { show = true, decimals = null, format = "ms", label = null, logBase = 1, min = 0, max = null },
    { show = true, decimals = null, format = "short", label = null, logBase = 1, min = 0, max = null }
  ]
}

############################################
# ElasticSearch Grafana - HTTP Resonse Codes
############################################
module "grafana_es_http_response_codes" {
  source = "git::https://github.com/synapsestudios/terraform-grafana-panel-graph.git?ref=release/v1.0.0"

  title           = "ElasticSearch ${var.namespace} HTTP Response Codes"
  null_point_mode = "null"
  description     = "The number of requests to a domain, aggregated by HTTP response code (2xx, 3xx, 4xx, 5xx)."
  lines           = false
  bars            = true
  interval        = "1m"

  queries = [
    {
      refId      = "A"
      region     = local.region
      namespace  = "AWS/ES"
      metricName = "2xx"
      statistics = ["Sum"]
      dimensions = { ClientId = data.aws_caller_identity.current.account_id, DomainName = aws_elasticsearch_domain.this[0].domain_name }
      alias      = "2XX"
      period     = "$bar_graph_interval"
    },
    {
      refId      = "B"
      region     = local.region
      namespace  = "AWS/ES"
      metricName = "3xx"
      statistics = ["Sum"]
      dimensions = { ClientId = data.aws_caller_identity.current.account_id, DomainName = aws_elasticsearch_domain.this[0].domain_name }
      alias      = "3XX"
      period     = "$bar_graph_interval"
    },
    {
      refId      = "C"
      region     = local.region
      namespace  = "AWS/ES"
      metricName = "4xx"
      statistics = ["Sum"]
      dimensions = { ClientId = data.aws_caller_identity.current.account_id, DomainName = aws_elasticsearch_domain.this[0].domain_name }
      alias      = "4XX"
      period     = "$bar_graph_interval"
    },
    {
      refId      = "D"
      region     = local.region
      namespace  = "AWS/ES"
      metricName = "5xx"
      statistics = ["Sum"]
      dimensions = { ClientId = data.aws_caller_identity.current.account_id, DomainName = aws_elasticsearch_domain.this[0].domain_name }
      alias      = "5XX"
      period     = "$bar_graph_interval"
    }
  ]

  yaxes = [
    { show = true, decimals = null, format = "short", label = null, logBase = 1, min = 0, max = null },
    { show = true, decimals = null, format = "short", label = null, logBase = 1, min = 0, max = null }
  ]

  legend = { show = true, alignAsTable = false, avg = false, current = false, max = false, min = false, sort = null, sortDesc = false, total = true, values = true }
}

##############################################
# ElasticSearch Grafana - Invalid Host Headers
##############################################
module "grafana_es_invalid_host_headers" {
  source = "git::https://github.com/synapsestudios/terraform-grafana-panel-graph.git?ref=release/v1.0.0"

  title           = "ElasticSearch ${var.namespace} Invalid Host Headers"
  null_point_mode = "connected"
  description     = "The total number of HTTP requests and the number of requests that included and invalid (or missing) host header. Valid requests include the domain endpoint as the host header."
  interval        = "1m"

  queries = [
    {
      refId      = "A"
      region     = local.region
      namespace  = "AWS/ES"
      metricName = "ElasticsearchRequests"
      statistics = ["Sum"]
      dimensions = { ClientId = data.aws_caller_identity.current.account_id, DomainName = aws_elasticsearch_domain.this[0].domain_name }
      alias      = "Requests"
      period     = "$__interval"
    },
    {
      refId      = "B"
      region     = local.region
      namespace  = "AWS/ES"
      metricName = "InvalidHostHeaderRequests"
      statistics = ["Sum"]
      dimensions = { ClientId = data.aws_caller_identity.current.account_id, DomainName = aws_elasticsearch_domain.this[0].domain_name }
      alias      = "Invalid Host Header Requests"
      period     = "$__interval"
    }
  ]

  alias_colors = { Requests = "dark-green", "Invalid Host Header Requests" = "dark-red" }

  legend = { show = true, alignAsTable = false, avg = true, current = true, max = true, min = true, sort = null, sortDesc = false, total = true, values = true }

  yaxes = [
    { show = true, decimals = null, format = "short", label = null, logBase = 1, min = null, max = null },
    { show = true, decimals = null, format = "short", label = null, logBase = 1, min = null, max = null }
  ]
}

######################################
# ElasticSearch Grafana - Thread Pools
######################################
module "grafana_es_thread_pools" {
  source = "git::https://github.com/synapsestudios/terraform-grafana-panel-graph.git?ref=release/v1.0.0"

  title           = "ElasticSearch ${var.namespace} Thread Pools"
  null_point_mode = "null"
  description     = "Metrics for the write, search, index, and merge thread pool: number of threads, tasks in the queue and rejected tasks. If the queue size is consistently high or rejected count is high, consider scaling your cluster."
  interval        = "1m"

  queries = [
    {
      refId      = "A"
      region     = local.region
      namespace  = "AWS/ES"
      metricName = "ThreadpoolWriteThreads"
      statistics = ["Maximum"]
      dimensions = { ClientId = data.aws_caller_identity.current.account_id, DomainName = aws_elasticsearch_domain.this[0].domain_name }
      alias      = "Write Thread Count"
      period     = "$__interval"
    },
    {
      refId      = "B"
      region     = local.region
      namespace  = "AWS/ES"
      metricName = "ThreadpoolWriteQueue"
      statistics = ["Maximum"]
      dimensions = { ClientId = data.aws_caller_identity.current.account_id, DomainName = aws_elasticsearch_domain.this[0].domain_name }
      alias      = "Write Queue Depth"
      period     = "$__interval"
    },
    {
      refId      = "C"
      region     = local.region
      namespace  = "AWS/ES"
      metricName = "ThreadpoolWriteRejected"
      statistics = ["Maximum"]
      dimensions = { ClientId = data.aws_caller_identity.current.account_id, DomainName = aws_elasticsearch_domain.this[0].domain_name }
      alias      = "Write Rejected Count"
      period     = "$__interval"
    },
    {
      refId      = "D"
      region     = local.region
      namespace  = "AWS/ES"
      metricName = "ThreadpoolIndexThreads"
      statistics = ["Maximum"]
      dimensions = { ClientId = data.aws_caller_identity.current.account_id, DomainName = aws_elasticsearch_domain.this[0].domain_name }
      alias      = "Index Thread Count"
      period     = "$__interval"
    },
    {
      refId      = "E"
      region     = local.region
      namespace  = "AWS/ES"
      metricName = "ThreadpoolIndexQueue"
      statistics = ["Maximum"]
      dimensions = { ClientId = data.aws_caller_identity.current.account_id, DomainName = aws_elasticsearch_domain.this[0].domain_name }
      alias      = "Index Queue Depth"
      period     = "$__interval"
    },
    {
      refId      = "F"
      region     = local.region
      namespace  = "AWS/ES"
      metricName = "ThreadpoolIndexRejected"
      statistics = ["Maximum"]
      dimensions = { ClientId = data.aws_caller_identity.current.account_id, DomainName = aws_elasticsearch_domain.this[0].domain_name }
      alias      = "Index Rejected Count"
      period     = "$__interval"
    },
    {
      refId      = "G"
      region     = local.region
      namespace  = "AWS/ES"
      metricName = "ThreadpoolSearchThreads"
      statistics = ["Maximum"]
      dimensions = { ClientId = data.aws_caller_identity.current.account_id, DomainName = aws_elasticsearch_domain.this[0].domain_name }
      alias      = "Search Thread Count"
      period     = "$__interval"
    },
    {
      refId      = "H"
      region     = local.region
      namespace  = "AWS/ES"
      metricName = "ThreadpoolSearchQueue"
      statistics = ["Maximum"]
      dimensions = { ClientId = data.aws_caller_identity.current.account_id, DomainName = aws_elasticsearch_domain.this[0].domain_name }
      alias      = "Search Queue Depth"
      period     = "$__interval"
    },
    {
      refId      = "I"
      region     = local.region
      namespace  = "AWS/ES"
      metricName = "ThreadpoolSearchRejected"
      statistics = ["Maximum"]
      dimensions = { ClientId = data.aws_caller_identity.current.account_id, DomainName = aws_elasticsearch_domain.this[0].domain_name }
      alias      = "Search Rejected Count"
      period     = "$__interval"
    },
    {
      refId      = "J"
      region     = local.region
      namespace  = "AWS/ES"
      metricName = "ThreadpoolForce_mergeThreads"
      statistics = ["Maximum"]
      dimensions = { ClientId = data.aws_caller_identity.current.account_id, DomainName = aws_elasticsearch_domain.this[0].domain_name }
      alias      = "Merge Thread Count"
      period     = "$__interval"
    },
    {
      refId      = "K"
      region     = local.region
      namespace  = "AWS/ES"
      metricName = "ThreadpoolForce_mergeQueue"
      statistics = ["Maximum"]
      dimensions = { ClientId = data.aws_caller_identity.current.account_id, DomainName = aws_elasticsearch_domain.this[0].domain_name }
      alias      = "Merge Queue Depth"
      period     = "$__interval"
    },
    {
      refId      = "L"
      region     = local.region
      namespace  = "AWS/ES"
      metricName = "ThreadpoolForce_mergeRejected"
      statistics = ["Maximum"]
      dimensions = { ClientId = data.aws_caller_identity.current.account_id, DomainName = aws_elasticsearch_domain.this[0].domain_name }
      alias      = "Merge Rejected Count"
      period     = "$__interval"
    }
  ]

  yaxes = [
    { show = true, decimals = 0, format = "short", label = null, logBase = 1, min = 0, max = null },
    { show = true, decimals = null, format = "short", label = null, logBase = 1, min = 0, max = null }
  ]
}
