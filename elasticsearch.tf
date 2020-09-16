locals {
  es_subnets = var.es_instance_count <= 2 ? [module.vpc.elasticache_subnets[0]] : module.vpc.elasticache_subnets
}

######################
# ElasticSearch Domain
######################
resource "aws_elasticsearch_domain" "this" {
  count = var.use_elasticsearch == true ? 1 : 0

  domain_name           = var.namespace
  elasticsearch_version = var.es_version
  tags                  = var.tags

  cluster_config {
    instance_type            = var.es_instance_type
    instance_count           = var.es_instance_count
    dedicated_master_enabled = var.es_dedicated_master_enabled
    dedicated_master_type    = var.es_dedicated_master_type
    dedicated_master_count   = var.es_dedicated_master_count
    zone_awareness_enabled   = var.es_zone_awareness_enabled

    dynamic "zone_awareness_config" {
      for_each = var.es_zone_awareness_enabled == true ? [1] : []
      content {
        availability_zone_count = var.es_availability_zone_count
      }
    }
  }

  snapshot_options {
    automated_snapshot_start_hour = var.es_snapshot_hour
  }

  ebs_options {
    ebs_enabled = true
    volume_type = var.es_volume_type
    volume_size = var.es_volume_size
  }

  vpc_options {
    subnet_ids         = local.es_subnets
    security_group_ids = [module.vpc.default_security_group_id, aws_security_group.elasticsearch[0].id]
  }

  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.elasticsearch[0].arn
    log_type                 = "INDEX_SLOW_LOGS"
  }

  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.elasticsearch[0].arn
    log_type                 = "SEARCH_SLOW_LOGS"
  }

  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.elasticsearch[0].arn
    log_type                 = "ES_APPLICATION_LOGS"
  }
}

###############################################
# IAM Policy Document for ElasticSearch Logging
###############################################
data "aws_iam_policy_document" "elasticsearch_logs" {
  statement {
    sid = "PutCloudWatchLogs"

    principals {
      type        = "Service"
      identifiers = ["es.amazonaws.com"]
    }

    actions = [
      "logs:PutLogEvents",
      "logs:PutLogEventsBatch",
      "logs:CreateLogStream",
    ]

    resources = ["arn:aws:logs:*"]
  }
}

#####################################
# CloudWatchLogPolicy - ElasticSearch
#####################################
resource "aws_cloudwatch_log_resource_policy" "elasticsearch" {
  count = var.use_elasticsearch == true ? 1 : 0

  policy_document = data.aws_iam_policy_document.elasticsearch_logs.json
  policy_name     = "elasticsearch-${var.namespace}-policy"
}

##########################
# LogGroup - ElasticSearch
##########################
resource "aws_cloudwatch_log_group" "elasticsearch" {
  count = var.use_elasticsearch == true ? 1 : 0

  name = "/${var.environment_name}/application/elasticsearch"
  tags = var.tags
}

##############################################
# IAM Policy Document for ElasticSearch Access
##############################################
data "aws_iam_policy_document" "elasticsearch_access" {
  statement {
    sid = "AllowElasticSearchAccess"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "es:*"
    ]

    # condition {
    #   test     = "IpAddress"
    #   variable = "aws:SourceIp"
    #   values   = [module.vpc.vpc_cidr_block]
    # }

    resources = var.use_elasticsearch == true ? ["${aws_elasticsearch_domain.this[0].arn}/*"] : []
  }
}

resource "aws_elasticsearch_domain_policy" "this" {
  count = var.use_elasticsearch == true ? 1 : 0

  domain_name     = aws_elasticsearch_domain.this[0].domain_name
  access_policies = data.aws_iam_policy_document.elasticsearch_access.json
}

##########################################
# Route53 CNAME for ElasticSearch Endpoint
##########################################
resource "aws_route53_record" "elasticsearch" {
  count = var.use_elasticsearch == true ? 1 : 0

  zone_id = local.zone_id
  name    = "elasticsearch"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_elasticsearch_domain.this[0].endpoint]
}

# TODO set this up as a redirect
# https://stackoverflow.com/questions/10115799/set-up-dns-based-url-forwarding-in-amazon-route53/14289082#14289082
########################################
# Route53 CNAME for ElasticSearch Kibana
########################################
resource "aws_route53_record" "kibana" {
  count = var.use_elasticsearch == true ? 1 : 0

  zone_id = local.zone_id
  name    = "kibana"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_elasticsearch_domain.this[0].endpoint]
}
