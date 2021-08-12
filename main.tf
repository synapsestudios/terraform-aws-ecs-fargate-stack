########
# Locals
########
locals {
  database_name = lower(var.namespace)
  database_port = (regex("postgres", var.database_engine) == "postgres") ? "5432" : "3306"
  zone_id       = var.private_dns == true ? aws_route53_zone.this[0].zone_id : data.aws_route53_zone.this[0].zone_id
  es_ports      = [80, 443]
}

################
# AWS Account ID
################
data "aws_caller_identity" "current" {}

####################
# AWS Current Region
####################
data "aws_region" "current" {}

#####################
# ECS - VPC & Subnets
#####################
module "vpc" {
  source                                 = "terraform-aws-modules/vpc/aws"
  version                                = "3.30"
  name                                   = var.namespace
  cidr                                   = var.vpc_cidr
  azs                                    = ["us-west-2a", "us-west-2b", "us-west-2c"]
  private_subnets                        = [cidrsubnet(var.vpc_cidr, 4, 0), cidrsubnet(var.vpc_cidr, 4, 1), cidrsubnet(var.vpc_cidr, 4, 2)]
  public_subnets                         = [cidrsubnet(var.vpc_cidr, 4, 3), cidrsubnet(var.vpc_cidr, 4, 4), cidrsubnet(var.vpc_cidr, 4, 5)]
  database_subnets                       = [cidrsubnet(var.vpc_cidr, 4, 6), cidrsubnet(var.vpc_cidr, 4, 7), cidrsubnet(var.vpc_cidr, 4, 8)]
  elasticache_subnets                    = [cidrsubnet(var.vpc_cidr, 4, 9), cidrsubnet(var.vpc_cidr, 4, 10), cidrsubnet(var.vpc_cidr, 4, 11)]
  enable_dns_hostnames                   = true
  enable_dns_support                     = true
  create_database_subnet_group           = false
  create_database_subnet_route_table     = var.database_publicly_accessible
  create_database_internet_gateway_route = var.database_publicly_accessible
  create_elasticache_subnet_group        = true
  create_elasticache_subnet_route_table  = true
  single_nat_gateway                     = var.single_nat_gateway
  enable_nat_gateway                     = true
  public_subnet_tags                     = { "immutable_metadata" = "{\"purpose\":\"${var.environment_name}-public\"}" }
  private_subnet_tags                    = { "immutable_metadata" = "{\"purpose\":\"${var.environment_name}-private\"}" }
  database_subnet_tags                   = { "immutable_metadata" = "{\"purpose\":\"${var.environment_name}-database\"}" }
  elasticache_subnet_tags                = { "immutable_metadata" = "{\"purpose\":\"${var.environment_name}-elasticache\"}" }
  tags                                   = var.tags
}

##################
# Route53 DNS Zone
##################
data "aws_route53_zone" "this" {
  count = var.private_dns == false ? 1 : 0

  name         = var.dns_zone
  private_zone = false
}

resource "aws_route53_zone" "this" {
  count = var.private_dns == true ? 1 : 0

  name = var.dns_zone
  vpc {
    vpc_id = module.vpc.vpc_id
  }
}

#################################
# ALB - Application Load Balancer
#################################
resource "aws_lb" "this" {
  name                       = "${var.namespace}-frontend"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.load_balancer.id]
  subnets                    = module.vpc.public_subnets
  enable_deletion_protection = false
  idle_timeout               = var.alb_ide_timeout
  tags                       = var.tags

  access_logs {
    bucket  = var.alb_access_logs_bucket
    prefix  = var.environment_name
    enabled = true
  }
}

#####################
# ALB - HTTP Listener
#####################
resource "aws_lb_listener" "http" {
  depends_on        = [aws_lb.this]
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

######################
# ALB - HTTPS Listener
######################
resource "aws_lb_listener" "https" {
  depends_on        = [aws_lb.this]
  load_balancer_arn = aws_lb.this.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.acm_certificate_arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Maintenance"
      status_code  = "200"
    }
  }
}

###############
# ECS - Cluster
###############
resource "aws_ecs_cluster" "this" {
  name               = var.namespace
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 100
  }
  tags = var.tags
}

###################
# Service Discovery
###################
resource "aws_service_discovery_private_dns_namespace" "this" {
  count = var.use_service_discovery == true ? 1 : 0

  name        = var.namespace
  description = "Service Discover for ${var.namespace}"
  vpc         = module.vpc.vpc_id
}
