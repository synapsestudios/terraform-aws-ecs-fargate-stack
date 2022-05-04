# AWS ECS Fargate Cluster Spinnaker Compatible

This module creates an opinionated AWS ECS Fargate cluster, VPC, SecurityGroups, RDS, ElastiCache, and ElasticSearch, resources are created with Spinnaker`s [naming conventions](https://docs.armory.io/docs/overview/naming-conventions/#spinnaker-naming-conventions) and is intended to be used in conjunction [synapsestudios/terraform-aws-ecs-deployment](https://github.com/synapsestudios/terraform-aws-ecs-fargate-stack), or with a fresh Spinnaker pipeline. This is module is the core module for any new environment.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 0.12.29 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 3.53 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 2.1 |
| <a name="requirement_template"></a> [template](#requirement\_template) | ~> 2.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 3.53 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | 3.7 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.elasticsearch](https://registry.terraform.io/providers/hashicorp/aws/3.53/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_resource_policy.elasticsearch](https://registry.terraform.io/providers/hashicorp/aws/3.53/docs/resources/cloudwatch_log_resource_policy) | resource |
| [aws_db_instance.this](https://registry.terraform.io/providers/hashicorp/aws/3.53/docs/resources/db_instance) | resource |
| [aws_db_subnet_group.this](https://registry.terraform.io/providers/hashicorp/aws/3.53/docs/resources/db_subnet_group) | resource |
| [aws_default_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/3.53/docs/resources/default_security_group) | resource |
| [aws_ecs_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/3.53/docs/resources/ecs_cluster) | resource |
| [aws_elasticache_replication_group.this](https://registry.terraform.io/providers/hashicorp/aws/3.53/docs/resources/elasticache_replication_group) | resource |
| [aws_elasticsearch_domain.this](https://registry.terraform.io/providers/hashicorp/aws/3.53/docs/resources/elasticsearch_domain) | resource |
| [aws_elasticsearch_domain_policy.this](https://registry.terraform.io/providers/hashicorp/aws/3.53/docs/resources/elasticsearch_domain_policy) | resource |
| [aws_lb.this](https://registry.terraform.io/providers/hashicorp/aws/3.53/docs/resources/lb) | resource |
| [aws_lb_listener.http](https://registry.terraform.io/providers/hashicorp/aws/3.53/docs/resources/lb_listener) | resource |
| [aws_lb_listener.https](https://registry.terraform.io/providers/hashicorp/aws/3.53/docs/resources/lb_listener) | resource |
| [aws_rds_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/3.53/docs/resources/rds_cluster) | resource |
| [aws_rds_cluster_instance.this](https://registry.terraform.io/providers/hashicorp/aws/3.53/docs/resources/rds_cluster_instance) | resource |
| [aws_route53_record.elasticsearch](https://registry.terraform.io/providers/hashicorp/aws/3.53/docs/resources/route53_record) | resource |
| [aws_route53_record.kibana](https://registry.terraform.io/providers/hashicorp/aws/3.53/docs/resources/route53_record) | resource |
| [aws_route53_record.postgres](https://registry.terraform.io/providers/hashicorp/aws/3.53/docs/resources/route53_record) | resource |
| [aws_route53_record.redis_replica_group](https://registry.terraform.io/providers/hashicorp/aws/3.53/docs/resources/route53_record) | resource |
| [aws_route53_zone.this](https://registry.terraform.io/providers/hashicorp/aws/3.53/docs/resources/route53_zone) | resource |
| [aws_security_group.database](https://registry.terraform.io/providers/hashicorp/aws/3.53/docs/resources/security_group) | resource |
| [aws_security_group.ecs_tasks](https://registry.terraform.io/providers/hashicorp/aws/3.53/docs/resources/security_group) | resource |
| [aws_security_group.elasticsearch](https://registry.terraform.io/providers/hashicorp/aws/3.53/docs/resources/security_group) | resource |
| [aws_security_group.load_balancer](https://registry.terraform.io/providers/hashicorp/aws/3.53/docs/resources/security_group) | resource |
| [aws_security_group.redis](https://registry.terraform.io/providers/hashicorp/aws/3.53/docs/resources/security_group) | resource |
| [aws_security_group_rule.database_command_synter](https://registry.terraform.io/providers/hashicorp/aws/3.53/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.database_ecs_access](https://registry.terraform.io/providers/hashicorp/aws/3.53/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.database_public_access](https://registry.terraform.io/providers/hashicorp/aws/3.53/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ecs_alb_access](https://registry.terraform.io/providers/hashicorp/aws/3.53/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ecs_egress_access](https://registry.terraform.io/providers/hashicorp/aws/3.53/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ecs_internal_access](https://registry.terraform.io/providers/hashicorp/aws/3.53/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.elasticsearch_command_synter](https://registry.terraform.io/providers/hashicorp/aws/3.53/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.elasticsearch_ecs_access](https://registry.terraform.io/providers/hashicorp/aws/3.53/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.elasticsearch_egress_access](https://registry.terraform.io/providers/hashicorp/aws/3.53/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.elasticsearch_node_access](https://registry.terraform.io/providers/hashicorp/aws/3.53/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.redis_command_synter](https://registry.terraform.io/providers/hashicorp/aws/3.53/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.redis_ecs_access](https://registry.terraform.io/providers/hashicorp/aws/3.53/docs/resources/security_group_rule) | resource |
| [aws_service_discovery_private_dns_namespace.this](https://registry.terraform.io/providers/hashicorp/aws/3.53/docs/resources/service_discovery_private_dns_namespace) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/3.53/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.elasticsearch_access](https://registry.terraform.io/providers/hashicorp/aws/3.53/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.elasticsearch_logs](https://registry.terraform.io/providers/hashicorp/aws/3.53/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/3.53/docs/data-sources/region) | data source |
| [aws_route53_zone.this](https://registry.terraform.io/providers/hashicorp/aws/3.53/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acm_certificate_arn"></a> [acm\_certificate\_arn](#input\_acm\_certificate\_arn) | ARN of the corresponding ACM SSL to use with the ALB Load Balancer. | `string` | n/a | yes |
| <a name="input_alb_access_logs_bucket"></a> [alb\_access\_logs\_bucket](#input\_alb\_access\_logs\_bucket) | Name of existing S3 bucket to store ALB access logs. | `string` | n/a | yes |
| <a name="input_alb_ide_timeout"></a> [alb\_ide\_timeout](#input\_alb\_ide\_timeout) | (Optional) The time in seconds that the connection is allowed to be idle. Only valid for Load Balancers of type application. Default: 60. | `number` | `60` | no |
| <a name="input_application_name"></a> [application\_name](#input\_application\_name) | Name of application. | `string` | n/a | yes |
| <a name="input_database_apply_immediately"></a> [database\_apply\_immediately](#input\_database\_apply\_immediately) | (Optional) Specifies whether any database modifications are applied immediately, or during the next maintenance window. Default is `true` | `bool` | `true` | no |
| <a name="input_database_backup_retention"></a> [database\_backup\_retention](#input\_database\_backup\_retention) | Number of days to retain RDS backups. | `number` | `10` | no |
| <a name="input_database_backup_window"></a> [database\_backup\_window](#input\_database\_backup\_window) | RDS backup window timeframe. | `string` | `"00:00-04:00"` | no |
| <a name="input_database_ca_cert"></a> [database\_ca\_cert](#input\_database\_ca\_cert) | CA Certificate Idendtifier, example: rds-ca-2019 | `string` | `"rds-ca-2019"` | no |
| <a name="input_database_deletion_protection"></a> [database\_deletion\_protection](#input\_database\_deletion\_protection) | If true, terraform will not allow database deletion. | `bool` | `true` | no |
| <a name="input_database_engine"></a> [database\_engine](#input\_database\_engine) | Database engine to provision. | `string` | `"postgres"` | no |
| <a name="input_database_engine_version"></a> [database\_engine\_version](#input\_database\_engine\_version) | Database engine to provision. | `string` | `"9.6.12"` | no |
| <a name="input_database_instance_count"></a> [database\_instance\_count](#input\_database\_instance\_count) | Number of RDS Instances | `number` | `2` | no |
| <a name="input_database_instance_type"></a> [database\_instance\_type](#input\_database\_instance\_type) | Database Instance Type. | `string` | `"db.t2.micro"` | no |
| <a name="input_database_log_types"></a> [database\_log\_types](#input\_database\_log\_types) | List of database log type to export to CloudWatch. Options: alert, audit, error, general, listener, slowquery, trace, postgresql, upgrade | `list` | `[]` | no |
| <a name="input_database_monitoring_interval"></a> [database\_monitoring\_interval](#input\_database\_monitoring\_interval) | (Optional) The interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB instance. To disable collecting Enhanced Monitoring metrics, specify 0. The default is 0. Valid Values: 0, 1, 5, 10, 15, 30, 60. | `number` | `0` | no |
| <a name="input_database_multi_az"></a> [database\_multi\_az](#input\_database\_multi\_az) | (Optional) Specifies if the RDS instance is multi-AZ | `bool` | `false` | no |
| <a name="input_database_name"></a> [database\_name](#input\_database\_name) | Name of the RDS Database. | `string` | n/a | yes |
| <a name="input_database_password"></a> [database\_password](#input\_database\_password) | Password for the RDS database. | `string` | n/a | yes |
| <a name="input_database_public_cidrs"></a> [database\_public\_cidrs](#input\_database\_public\_cidrs) | List of CIDR blocks allowed to connect to database when public access is enabled | `list(string)` | `[]` | no |
| <a name="input_database_publicly_accessible"></a> [database\_publicly\_accessible](#input\_database\_publicly\_accessible) | (Optional) Bool to control if instance is publicly accessible. Default is false. | `bool` | `false` | no |
| <a name="input_database_skip_final_snapshot"></a> [database\_skip\_final\_snapshot](#input\_database\_skip\_final\_snapshot) | If true, a database snapshot will NOT be performed before destruction. | `bool` | `true` | no |
| <a name="input_database_storage_encrypted"></a> [database\_storage\_encrypted](#input\_database\_storage\_encrypted) | (Optional) Specifies whether the DB instance is encrypted. | `bool` | `false` | no |
| <a name="input_database_storage_size"></a> [database\_storage\_size](#input\_database\_storage\_size) | Storage size in gigabytes to allocate for RDS instances. | `number` | `10` | no |
| <a name="input_database_storage_type"></a> [database\_storage\_type](#input\_database\_storage\_type) | EC2 Storage type to use with RDS instances. | `string` | `"gp2"` | no |
| <a name="input_database_username"></a> [database\_username](#input\_database\_username) | Username for the RDS database. | `string` | n/a | yes |
| <a name="input_disable_db"></a> [disable\_db](#input\_disable\_db) | If true, this setting will prevent this module from creating an RDS database | `bool` | `false` | no |
| <a name="input_dns_zone"></a> [dns\_zone](#input\_dns\_zone) | Name of the DNS zone to use with this deployment. | `string` | n/a | yes |
| <a name="input_environment_name"></a> [environment\_name](#input\_environment\_name) | Name of environment. | `string` | n/a | yes |
| <a name="input_es_availability_zone_count"></a> [es\_availability\_zone\_count](#input\_es\_availability\_zone\_count) | (Optional) Number of Availability Zones for the ElasticSearch domain to use with zone\_awareness\_enabled. Defaults to 2. Valid values: 2 or 3. | `number` | `2` | no |
| <a name="input_es_dedicated_master_count"></a> [es\_dedicated\_master\_count](#input\_es\_dedicated\_master\_count) | (Optional) Number of dedicated master nodes in the ElasticSearch cluster | `number` | `null` | no |
| <a name="input_es_dedicated_master_enabled"></a> [es\_dedicated\_master\_enabled](#input\_es\_dedicated\_master\_enabled) | (Optional) Indicates whether dedicated master nodes are enabled for the ElasticSearch cluster. | `bool` | `null` | no |
| <a name="input_es_dedicated_master_type"></a> [es\_dedicated\_master\_type](#input\_es\_dedicated\_master\_type) | (Optional) Instance type of the dedicated master nodes in the ElasticSearch cluster. | `string` | `null` | no |
| <a name="input_es_instance_count"></a> [es\_instance\_count](#input\_es\_instance\_count) | Number of instances in the ElasticSearch domain. | `number` | `3` | no |
| <a name="input_es_instance_type"></a> [es\_instance\_type](#input\_es\_instance\_type) | The instance type to use with the elastic search domain. | `string` | `"t2.small.elasticsearch"` | no |
| <a name="input_es_snapshot_hour"></a> [es\_snapshot\_hour](#input\_es\_snapshot\_hour) | Hour of day in which the ElasticSearch domain takes a snapshot. | `number` | `23` | no |
| <a name="input_es_version"></a> [es\_version](#input\_es\_version) | The version of Elasticsearch to deploy. Defaults to 1.5 | `string` | `"1.5"` | no |
| <a name="input_es_volume_size"></a> [es\_volume\_size](#input\_es\_volume\_size) | Size in GB of the EBS volumes on the ElasticSearch instances. | `number` | `10` | no |
| <a name="input_es_volume_type"></a> [es\_volume\_type](#input\_es\_volume\_type) | Type of EBS volume to use on the ElasticSearch instances. | `string` | `"gp2"` | no |
| <a name="input_es_zone_awareness_enabled"></a> [es\_zone\_awareness\_enabled](#input\_es\_zone\_awareness\_enabled) | Optional) Indicates whether zone awareness is enabled on the ElasticSearch domain, set to true for multi-az deployment. To enable awareness with three Availability Zones, the availability\_zone\_count within the zone\_awareness\_config must be set to 3. | `bool` | `false` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Determines naming convention of assets. Generally follows DNS naming convention. | `string` | n/a | yes |
| <a name="input_private_dns"></a> [private\_dns](#input\_private\_dns) | If true, private DNS zones will be used. | `bool` | `false` | no |
| <a name="input_redis_cluster_mode"></a> [redis\_cluster\_mode](#input\_redis\_cluster\_mode) | (Optional) Create a native redis cluster. automatic\_failover\_enabled must be set to true. Cluster Mode documented below. Only 1 cluster\_mode block is allowed. | `list(object({ replicas_per_node_group = number, num_node_groups = number }))` | `[]` | no |
| <a name="input_redis_engine_version"></a> [redis\_engine\_version](#input\_redis\_engine\_version) | Engine version to use with the ElastiCache Redis deployment. | `string` | `"5.0.6"` | no |
| <a name="input_redis_instance_count"></a> [redis\_instance\_count](#input\_redis\_instance\_count) | Number of instances to provision in Redis ElastiCache deployment (Replication Group). | `number` | `1` | no |
| <a name="input_redis_instance_type"></a> [redis\_instance\_type](#input\_redis\_instance\_type) | Instace Type to use in Redis ElastiCache deployment. | `string` | `"cache.t2.micro"` | no |
| <a name="input_redis_parameter_group_name"></a> [redis\_parameter\_group\_name](#input\_redis\_parameter\_group\_name) | Parameter group name to use with ElastiCache Redis deployment. | `string` | `"default.redis5.0"` | no |
| <a name="input_single_nat_gateway"></a> [single\_nat\_gateway](#input\_single\_nat\_gateway) | If true, only one NAT Gateway will be provisioned VS one per AZ. | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the AWS resources. | `map(string)` | n/a | yes |
| <a name="input_use_aurora"></a> [use\_aurora](#input\_use\_aurora) | If true, an Aurora Database cluster will be provisioned. | `bool` | `false` | no |
| <a name="input_use_elasticsearch"></a> [use\_elasticsearch](#input\_use\_elasticsearch) | If true, an ElasticSeach Domain will be provisioned. | `bool` | `false` | no |
| <a name="input_use_redis"></a> [use\_redis](#input\_use\_redis) | If true, a Redis ElastiCache cluster will be provisioned. | `bool` | `false` | no |
| <a name="input_use_service_discovery"></a> [use\_service\_discovery](#input\_use\_service\_discovery) | If true, service discovery will be setup using the namespace value as private DNS domain. | `bool` | `false` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | Network CIDR to use for new VPC. | `string` | `"10.0.0.0/20"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | ECS Cluster name for this environment. |
| <a name="output_database_address"></a> [database\_address](#output\_database\_address) | Database endpoint address. |
| <a name="output_database_endpoint"></a> [database\_endpoint](#output\_database\_endpoint) | Database Endpoint. |
| <a name="output_database_endpoint_reader"></a> [database\_endpoint\_reader](#output\_database\_endpoint\_reader) | Database Endpoint. |
| <a name="output_database_security_group"></a> [database\_security\_group](#output\_database\_security\_group) | Database SecurityGroup ID. |
| <a name="output_database_subnets"></a> [database\_subnets](#output\_database\_subnets) | List of Database subnet IDs. |
| <a name="output_dns_zone_id"></a> [dns\_zone\_id](#output\_dns\_zone\_id) | Route53 DNS Zone ID. |
| <a name="output_ecs_cluster_arn"></a> [ecs\_cluster\_arn](#output\_ecs\_cluster\_arn) | ECS Cluster ARN for this environment. |
| <a name="output_ecs_tasks_security_group"></a> [ecs\_tasks\_security\_group](#output\_ecs\_tasks\_security\_group) | ECS Tasks SecurityGroup ID. |
| <a name="output_elasticsearch_security_group"></a> [elasticsearch\_security\_group](#output\_elasticsearch\_security\_group) | ElasticSeasrch SecurityGroup ID. |
| <a name="output_es_endpoint"></a> [es\_endpoint](#output\_es\_endpoint) | ElasticSearch domain-specific endpoint used to submit index, search, and data upload requests. |
| <a name="output_http_listener_arn"></a> [http\_listener\_arn](#output\_http\_listener\_arn) | HTTP Listener ARN. |
| <a name="output_https_listener_arn"></a> [https\_listener\_arn](#output\_https\_listener\_arn) | HTTPS Listener ARN. |
| <a name="output_load_balancer_arn"></a> [load\_balancer\_arn](#output\_load\_balancer\_arn) | LoadBalancer ARN. |
| <a name="output_load_balancer_security_group"></a> [load\_balancer\_security\_group](#output\_load\_balancer\_security\_group) | LoadBalancer SecurityGroup ID. |
| <a name="output_private_subnets"></a> [private\_subnets](#output\_private\_subnets) | List of Private subnet IDs. |
| <a name="output_public_subnets"></a> [public\_subnets](#output\_public\_subnets) | List of Public subnet IDs. |
| <a name="output_redis_security_group"></a> [redis\_security\_group](#output\_redis\_security\_group) | Redis SecurityGroup ID. |
| <a name="output_service_discovery_namespace_id"></a> [service\_discovery\_namespace\_id](#output\_service\_discovery\_namespace\_id) | Service Discovery Namespace ID. |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | VPC ID Created for this environment. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->