# AWS ECS Fargate Cluster Spinnaker Compatible

This module creates an AWS ECS Fargate cluster, VPC, SecurityGroups, RDS, ElastiCache, and ElasticSearch, with naming conventions compatible with Spinnaker. This is module is the core module for any new environment.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| terraform | ~> 0.12.6 |
| aws | ~> 2.53 |
| null | ~> 2.1 |
| template | ~> 2.1 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 2.53 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| acm\_certificate\_arn | ARN of the corresponding ACM SSL to use with the ALB Load Balancer. | `string` | n/a | yes |
| alb\_access\_logs\_bucket | Name of existing S3 bucket to store ALB access logs. | `string` | n/a | yes |
| application\_name | Name of application. | `string` | n/a | yes |
| database\_name | Name of the RDS Database. | `string` | n/a | yes |
| database\_password | Password for the RDS database. | `string` | n/a | yes |
| database\_username | Username for the RDS database. | `string` | n/a | yes |
| dns\_zone | Name of the DNS zone to use with this deployment. | `string` | n/a | yes |
| environment\_name | Name of environment. | `string` | n/a | yes |
| namespace | Determines naming convention of assets. Generally follows DNS naming convention. | `string` | n/a | yes |
| tags | A mapping of tags to assign to the AWS resources. | `map(string)` | n/a | yes |
| alb\_ide\_timeout | (Optional) The time in seconds that the connection is allowed to be idle. Only valid for Load Balancers of type application. Default: 60. | `number` | `60` | no |
| database\_apply\_immediately | (Optional) Specifies whether any database modifications are applied immediately, or during the next maintenance window. Default is `true` | `bool` | `true` | no |
| database\_backup\_retention | Number of days to retain RDS backups. | `number` | `10` | no |
| database\_backup\_window | RDS backup window timeframe. | `string` | `"00:00-04:00"` | no |
| database\_ca\_cert | CA Certificate Idendtifier, example: rds-ca-2019 | `string` | `"rds-ca-2019"` | no |
| database\_deletion\_protection | If true, terraform will not allow database deletion. | `bool` | `true` | no |
| database\_engine | Database engine to provision. | `string` | `"postgres"` | no |
| database\_engine\_version | Database engine to provision. | `string` | `"9.6.12"` | no |
| database\_instance\_count | Number of RDS Instances | `number` | `2` | no |
| database\_instance\_type | Database Instance Type. | `string` | `"db.t2.micro"` | no |
| database\_log\_types | List of database log type to export to CloudWatch. Options: alert, audit, error, general, listener, slowquery, trace, postgresql, upgrade | `list` | `[]` | no |
| database\_monitoring\_interval | (Optional) The interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB instance. To disable collecting Enhanced Monitoring metrics, specify 0. The default is 0. Valid Values: 0, 1, 5, 10, 15, 30, 60. | `number` | `0` | no |
| database\_multi\_az | (Optional) Specifies if the RDS instance is multi-AZ | `bool` | `false` | no |
| database\_public\_cidrs | List of CIDR blocks allowed to connect to database when public access is enabled | `list(string)` | `[]` | no |
| database\_publicly\_accessible | (Optional) Bool to control if instance is publicly accessible. Default is false. | `bool` | `false` | no |
| database\_skip\_final\_snapshot | If true, a database snapshot will NOT be performed before destruction. | `bool` | `true` | no |
| database\_storage\_encrypted | (Optional) Specifies whether the DB instance is encrypted. | `bool` | `false` | no |
| database\_storage\_size | Storage size in gigabytes to allocate for RDS instances. | `number` | `10` | no |
| database\_storage\_type | EC2 Storage type to use with RDS instances. | `string` | `"gp2"` | no |
| es\_availability\_zone\_count | (Optional) Number of Availability Zones for the ElasticSearch domain to use with zone\_awareness\_enabled. Defaults to 2. Valid values: 2 or 3. | `number` | `2` | no |
| es\_dedicated\_master\_count | (Optional) Number of dedicated master nodes in the ElasticSearch cluster | `number` | `null` | no |
| es\_dedicated\_master\_enabled | (Optional) Indicates whether dedicated master nodes are enabled for the ElasticSearch cluster. | `bool` | `null` | no |
| es\_dedicated\_master\_type | (Optional) Instance type of the dedicated master nodes in the ElasticSearch cluster. | `string` | `null` | no |
| es\_instance\_count | Number of instances in the ElasticSearch domain. | `number` | `3` | no |
| es\_instance\_type | The instance type to use with the elastic search domain. | `string` | `"t2.small.elasticsearch"` | no |
| es\_snapshot\_hour | Hour of day in which the ElasticSearch domain takes a snapshot. | `number` | `23` | no |
| es\_version | The version of Elasticsearch to deploy. Defaults to 1.5 | `string` | `"1.5"` | no |
| es\_volume\_size | Size in GB of the EBS volumes on the ElasticSearch instances. | `number` | `10` | no |
| es\_volume\_type | Type of EBS volume to use on the ElasticSearch instances. | `string` | `"gp2"` | no |
| es\_zone\_awareness\_enabled | Optional) Indicates whether zone awareness is enabled on the ElasticSearch domain, set to true for multi-az deployment. To enable awareness with three Availability Zones, the availability\_zone\_count within the zone\_awareness\_config must be set to 3. | `bool` | `false` | no |
| private\_dns | If true, private DNS zones will be used. | `bool` | `false` | no |
| redis\_cluster\_mode | (Optional) Create a native redis cluster. automatic\_failover\_enabled must be set to true. Cluster Mode documented below. Only 1 cluster\_mode block is allowed. | `list(object({ replicas_per_node_group = number, num_node_groups = number }))` | `[]` | no |
| redis\_engine\_version | Engine version to use with the ElastiCache Redis deployment. | `string` | `"5.0.6"` | no |
| redis\_instance\_count | Number of instances to provision in Redis ElastiCache deployment (Replication Group). | `number` | `1` | no |
| redis\_instance\_type | Instace Type to use in Redis ElastiCache deployment. | `string` | `"cache.t2.micro"` | no |
| redis\_parameter\_group\_name | Parameter group name to use with ElastiCache Redis deployment. | `string` | `"default.redis5.0"` | no |
| single\_nat\_gateway | If true, only one NAT Gateway will be provisioned VS one per AZ. | `bool` | `true` | no |
| use\_aurora | If true, an Aurora Database cluster will be provisioned. | `bool` | `false` | no |
| use\_elasticsearch | If true, an ElasticSeach Domain will be provisioned. | `bool` | `false` | no |
| use\_redis | If true, a Redis ElastiCache cluster will be provisioned. | `bool` | `false` | no |
| use\_service\_discovery | If true, service discovery will be setup using the namespace value as private DNS domain. | `bool` | `false` | no |
| vpc\_cidr | Network CIDR to use for new VPC. | `string` | `"10.0.0.0/20"` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster\_name | ECS Cluster name for this environment. |
| database\_address | Database endpoint address. |
| database\_endpoint | Database Endpoint. |
| database\_endpoint\_reader | Database Endpoint. |
| database\_security\_group | Database SecurityGroup ID. |
| database\_subnets | List of Database subnet IDs. |
| dns\_zone\_id | Route53 DNS Zone ID. |
| ecs\_cluster\_arn | ECS Cluster ARN for this environment. |
| ecs\_tasks\_security\_group | ECS Tasks SecurityGroup ID. |
| elasticsearch\_security\_group | ElasticSeasrch SecurityGroup ID. |
| es\_endpoint | ElasticSearch domain-specific endpoint used to submit index, search, and data upload requests. |
| grafana\_alb\_connection\_count | Grafana Panel for ALB Connection Counts. |
| grafana\_alb\_http\_response\_code | Grafana Panel for ALB HTTP Response Codes. |
| grafana\_alb\_http\_target\_response\_code | Grafana Panel for ALB HTTP Target Response Codes. |
| grafana\_alb\_response\_time\_bargauge | Grafan Meter Panel for ALB Response Times. |
| grafana\_es\_cluster\_status | Grafana Panel for ElasticSearch Cluster Status. |
| grafana\_es\_cpu\_utilization\_data\_nodes | Grafana Panel for ElasticSearch CPU Utilization On All Data Nodes. |
| grafana\_es\_deleted\_documents | Grafana Panel for ElasticSearch Deleted Documents. |
| grafana\_es\_free\_storage\_space | Grafana Panel for ElasticSearch Free Storage Space. |
| grafana\_es\_http\_response\_codes | Grafana Panel for ElasticSearch HTTP Response Codes. |
| grafana\_es\_indexing\_latency | Grafana Panel for ElasticSearch Indexing Latency. |
| grafana\_es\_indexing\_rate | Grafana Panel for ElasticSearch Indexing Rate. |
| grafana\_es\_invalid\_host\_headers | Grafana Panel for ElasticSearch Invalid Host Header Requests. |
| grafana\_es\_search\_latency | Grafana Panel for ElasticSearch Search Latency. |
| grafana\_es\_search\_rate | Grafana Panel for ElasticSearch Search Rate. |
| grafana\_es\_searchable\_documents | Grafana Panel for ElasticSearch Searchable Documents. |
| grafana\_es\_thread\_pools | Grafana Panel for ElasticSearch Thread Pools. |
| grafana\_es\_total\_nodes | Grafana Panel for ElasticSearch Total Nodes. |
| grafana\_rds\_available\_memory | Grafana Panel for RDS Available Memory. |
| grafana\_rds\_cpu\_credit | Grafana Panel for RDS CPU Credit Usage. |
| grafana\_rds\_cpu\_utilization | Grafana Panel for RDS CPU Utilization. |
| grafana\_rds\_disk\_iops | Grafana Panel for RDS Disk IOPS. |
| grafana\_rds\_disk\_latency | Grafana Panel for RDS Disk Latency. |
| grafana\_rds\_disk\_queue\_depth | Grafana Panel for RDS Disk Queue Depth. |
| grafana\_rds\_disk\_throughput | Grafana Panel for RDS Disk Throughput. |
| grafana\_rds\_network\_traffic | Grafana Panel for RDS Network Traffic. |
| grafana\_rds\_storage\_space | Grafana Panel for RDS Storage Space. |
| grafana\_rds\_swap\_usage | Grafana Panel for RDS Swap Usage. |
| grafana\_redis\_bytes\_used\_for\_cache\_and\_replication | Grafana Panel for Redis Bytes Used For Cache / Bytes Used For Replication. |
| grafana\_redis\_cache | Grafana Panel for Redis Cache Stats. |
| grafana\_redis\_commands | Grafana Panel for Redis Command Stats. |
| grafana\_redis\_connections | Grafana Panel for Redis Connections. |
| grafana\_redis\_cpu\_utilization | Grafana Panel for Redis CPU Utilization. |
| grafana\_redis\_hyperlog\_replication\_lag | Grafana Panel for Redis HyperLog / Replication Lag. |
| grafana\_redis\_items | Grafana Panel for Redis Save In Progress / Current Connections. |
| grafana\_redis\_memory\_and\_swap | Grafana Panel for Redis Freeable Memory / Swap Usage. |
| grafana\_redis\_network\_traffic | Grafana Panel for Redis Network Traffic. |
| grafna\_alb\_request\_count\_target\_response\_time | Grafana Panel for ALB RequestCount / TargetResponseTime. |
| http\_listener\_arn | HTTP Listener ARN. |
| https\_listener\_arn | HTTPS Listener ARN. |
| load\_balancer\_arn | LoadBalancer ARN. |
| load\_balancer\_security\_group | LoadBalancer SecurityGroup ID. |
| private\_subnets | List of Private subnet IDs. |
| public\_subnets | List of Public subnet IDs. |
| redis\_security\_group | Redis SecurityGroup ID. |
| service\_discovery\_namespace\_id | Service Discovery Namespace ID. |
| vpc\_id | VPC ID Created for this environment. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->