#####################
# RDS Single Instance
#####################
resource "aws_db_instance" "this" {
  count = var.use_aurora || var.disable_db ? 0 : 1

  allocated_storage               = var.database_storage_size
  apply_immediately               = var.database_apply_immediately
  backup_retention_period         = var.database_backup_retention
  backup_window                   = var.database_backup_window
  ca_cert_identifier              = var.database_ca_cert
  db_subnet_group_name            = aws_db_subnet_group.this.name
  deletion_protection             = var.database_deletion_protection
  enabled_cloudwatch_logs_exports = var.database_log_types
  engine                          = var.database_engine
  engine_version                  = var.database_engine_version
  identifier                      = var.namespace
  instance_class                  = var.database_instance_type
  monitoring_interval             = var.database_monitoring_interval
  multi_az                        = var.database_multi_az
  name                            = var.database_name
  password                        = var.database_password
  publicly_accessible             = var.database_publicly_accessible
  skip_final_snapshot             = var.database_skip_final_snapshot
  storage_encrypted               = var.database_storage_encrypted
  storage_type                    = var.database_storage_type
  username                        = var.database_username
  vpc_security_group_ids          = [module.vpc.default_security_group_id, aws_security_group.database.id]
  tags                            = var.tags
}

####################
# RDS Aurora Cluster
####################
resource "aws_rds_cluster" "this" {
  count = var.use_aurora && ! var.disable_db ? 1 : 0

  cluster_identifier      = var.namespace
  engine                  = var.database_engine
  engine_version          = var.database_engine_version
  availability_zones      = module.vpc.azs
  database_name           = var.database_name
  master_username         = var.database_username
  master_password         = var.database_password
  db_subnet_group_name    = aws_db_subnet_group.this.name
  apply_immediately       = true
  deletion_protection     = var.database_deletion_protection
  skip_final_snapshot     = var.database_skip_final_snapshot
  backup_retention_period = var.database_backup_retention
  preferred_backup_window = var.database_backup_window
  storage_encrypted       = var.database_storage_encrypted
  vpc_security_group_ids  = [module.vpc.default_security_group_id, aws_security_group.database.id]
  tags                    = var.tags
}

resource "aws_rds_cluster_instance" "this" {
  count = var.use_aurora && ! var.disable_db ? var.database_instance_count : 0

  engine               = var.database_engine
  engine_version       = var.database_engine_version
  identifier           = "${var.namespace}-0${count.index + 1}"
  cluster_identifier   = aws_rds_cluster.this[0].id
  instance_class       = var.database_instance_type
  db_subnet_group_name = aws_db_subnet_group.this.name
  tags                 = var.tags
}

# resource "aws_rds_cluster_endpoint" "writer" {
#   count = var.use_aurora ? var.database_instance_count : 0

#   cluster_identifier          = "${aws_rds_cluster.default.id}"
#   cluster_endpoint_identifier = "reader"
#   custom_endpoint_type        = "READER"

#   excluded_members = [
#     "${aws_rds_cluster_instance.test1.id}",
#     "${aws_rds_cluster_instance.test2.id}",
#   ]
# }

################################
# Route53 CNAME for RDS Endpoint
################################
resource "aws_route53_record" "postgres" {
  count   = var.disable_db ? 0 : 1
  zone_id = local.zone_id
  name    = "postgres"
  type    = "CNAME"
  ttl     = "300"
  records = length(aws_db_instance.this) >= 1 ? [aws_db_instance.this[0].address] : [aws_rds_cluster.this[0].endpoint]
}

####################
# RDS - Subnet Group
####################
resource "aws_db_subnet_group" "this" {
  name        = var.namespace
  description = "RDS - ${var.namespace} Subnet Group"
  subnet_ids  = module.vpc.database_subnets
  tags        = var.tags
}
