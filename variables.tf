#############
# Application
#############
variable "application_name" {
  type        = string
  description = "Name of application."
}

variable "environment_name" {
  type        = string
  description = "Name of environment."
}

variable "namespace" {
  type        = string
  description = "Determines naming convention of assets. Generally follows DNS naming convention."
}

variable "dns_zone" {
  type        = string
  description = "Name of the DNS zone to use with this deployment."
}

variable "single_nat_gateway" {
  type        = bool
  description = "If true, only one NAT Gateway will be provisioned VS one per AZ."
  default     = true
}

####################################
# Networking - VPCs,Subnets, & CIDRs
####################################
variable "vpc_cidr" {
  type        = string
  description = "Network CIDR to use for new VPC."
  default     = "10.0.0.0/20"
}

variable "alb_access_logs_bucket" {
  type        = string
  description = "Name of existing S3 bucket to store ALB access logs."
}

variable "alb_ide_timeout" {
  type        = number
  description = "(Optional) The time in seconds that the connection is allowed to be idle. Only valid for Load Balancers of type application. Default: 60."
  default     = 60
}

#########################
# RDS - Database Settings
#########################
variable "disable_db" {
  type        = bool
  description = "If true, this setting will prevent this module from creating an RDS database"
  default     = false
}

variable "use_aurora" {
  type        = bool
  description = "If true, an Aurora Database cluster will be provisioned."
  default     = false
}

variable "database_engine" {
  type        = string
  description = "Database engine to provision."
  default     = "postgres"
}

variable "database_engine_version" {
  type        = string
  description = "Database engine to provision."
  default     = "9.6.12"
}

variable "database_instance_type" {
  type        = string
  description = "Database Instance Type."
  default     = "db.t2.micro"
}

variable "database_instance_count" {
  type        = number
  description = "Number of RDS Instances"
  default     = 2
}

variable "database_deletion_protection" {
  type        = bool
  description = "If true, terraform will not allow database deletion."
  default     = true
}

variable "database_skip_final_snapshot" {
  type        = bool
  description = "If true, a database snapshot will NOT be performed before destruction."
  default     = true
}

variable "database_backup_window" {
  type        = string
  description = "RDS backup window timeframe."
  default     = "00:00-04:00"
}

variable "database_backup_retention" {
  type        = number
  description = "Number of days to retain RDS backups."
  default     = 10
}

variable "database_storage_type" {
  type        = string
  description = "EC2 Storage type to use with RDS instances."
  default     = "gp2"
}

variable "database_storage_size" {
  type        = number
  description = "Storage size in gigabytes to allocate for RDS instances."
  default     = 10
}

variable "database_ca_cert" {
  type        = string
  description = "CA Certificate Idendtifier, example: rds-ca-2019"
  default     = "rds-ca-2019"
}

variable "database_name" {
  type        = string
  description = "Name of the RDS Database."
}

variable "database_username" {
  type        = string
  description = "Username for the RDS database."
}

variable "database_password" {
  type        = string
  description = "Password for the RDS database."
}

variable "database_log_types" {
  type        = list
  description = "List of database log type to export to CloudWatch. Options: alert, audit, error, general, listener, slowquery, trace, postgresql, upgrade"
  default     = []
}

variable "database_monitoring_interval" {
  type        = number
  description = "(Optional) The interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB instance. To disable collecting Enhanced Monitoring metrics, specify 0. The default is 0. Valid Values: 0, 1, 5, 10, 15, 30, 60."
  default     = 0
}

variable "database_publicly_accessible" {
  type        = bool
  description = "(Optional) Bool to control if instance is publicly accessible. Default is false."
  default     = false
}

variable "database_public_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks allowed to connect to database when public access is enabled"
  default     = []
}

variable "database_multi_az" {
  type        = bool
  description = "(Optional) Specifies if the RDS instance is multi-AZ"
  default     = false
}

variable "database_storage_encrypted" {
  type        = bool
  description = "(Optional) Specifies whether the DB instance is encrypted."
  default     = false
}

variable "database_apply_immediately" {
  type        = bool
  description = "(Optional) Specifies whether any database modifications are applied immediately, or during the next maintenance window. Default is `true`"
  default     = true
}

#####################
# ElastiCache - Redis
#####################
variable "use_redis" {
  type        = bool
  description = "If true, a Redis ElastiCache cluster will be provisioned."
  default     = false
}

variable "redis_instance_type" {
  type        = string
  description = "Instace Type to use in Redis ElastiCache deployment."
  default     = "cache.t2.micro"
}

variable "redis_instance_count" {
  type        = number
  description = "Number of instances to provision in Redis ElastiCache deployment (Replication Group)."
  default     = 1
}

variable "redis_engine_version" {
  type        = string
  description = "Engine version to use with the ElastiCache Redis deployment."
  default     = "5.0.6"
}

variable "redis_parameter_group_name" {
  type        = string
  description = "Parameter group name to use with ElastiCache Redis deployment."
  default     = "default.redis5.0"
}

variable "redis_cluster_mode" {
  type        = list(object({ replicas_per_node_group = number, num_node_groups = number }))
  description = "(Optional) Create a native redis cluster. automatic_failover_enabled must be set to true. Cluster Mode documented below. Only 1 cluster_mode block is allowed."
  default     = []
}

variable "acm_certificate_arn" {
  type        = string
  description = "ARN of the corresponding ACM SSL to use with the ALB Load Balancer."
}

variable "private_dns" {
  type        = bool
  description = "If true, private DNS zones will be used."
  default     = false
}

# ElasticSearch variables
variable "use_elasticsearch" {
  type        = bool
  description = "If true, an ElasticSeach Domain will be provisioned."
  default     = false
}

variable "es_version" {
  type        = string
  description = "The version of Elasticsearch to deploy. Defaults to 1.5"
  default     = "1.5"
}

variable "es_instance_type" {
  type        = string
  description = "The instance type to use with the elastic search domain."
  default     = "t2.small.elasticsearch"
}

variable "es_snapshot_hour" {
  type        = number
  description = "Hour of day in which the ElasticSearch domain takes a snapshot."
  default     = 23
}

variable "es_instance_count" {
  type        = number
  description = "Number of instances in the ElasticSearch domain."
  default     = 3
}

variable "es_volume_type" {
  type        = string
  description = "Type of EBS volume to use on the ElasticSearch instances."
  default     = "gp2"
}

variable "es_volume_size" {
  type        = number
  description = "Size in GB of the EBS volumes on the ElasticSearch instances."
  default     = 10
}

variable "use_service_discovery" {
  type        = bool
  description = "If true, service discovery will be setup using the namespace value as private DNS domain."
  default     = false
}

variable "es_dedicated_master_enabled" {
  type        = bool
  description = "(Optional) Indicates whether dedicated master nodes are enabled for the ElasticSearch cluster."
  default     = null
}

variable "es_dedicated_master_type" {
  type        = string
  description = "(Optional) Instance type of the dedicated master nodes in the ElasticSearch cluster."
  default     = null
}

variable "es_dedicated_master_count" {
  type        = number
  description = " (Optional) Number of dedicated master nodes in the ElasticSearch cluster"
  default     = null
}

variable "es_zone_awareness_enabled" {
  type        = bool
  description = "Optional) Indicates whether zone awareness is enabled on the ElasticSearch domain, set to true for multi-az deployment. To enable awareness with three Availability Zones, the availability_zone_count within the zone_awareness_config must be set to 3."
  default     = false
}

variable "es_availability_zone_count" {
  type        = number
  description = "(Optional) Number of Availability Zones for the ElasticSearch domain to use with zone_awareness_enabled. Defaults to 2. Valid values: 2 or 3."
  default     = 2
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the AWS resources."
}
