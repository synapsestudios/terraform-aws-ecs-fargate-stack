#######################################
# Security Group - VPC Default Deny All
#######################################
resource "aws_default_security_group" "this" {
  vpc_id = module.vpc.vpc_id
  tags   = merge(var.tags, { Name = "DoNotUse" })

  # TODO This is a CommandSynter limitation and should be addressed
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow outgoing connections"
  }
  # ingress {
  #   from_port   = 0
  #   to_port     = 0
  #   protocol    = -1
  #   self        = true
  #   description = "Deny all traffic on VPCs Default Security Group"
  # }
}

#################################
# Security Group - Load Balancer
#################################
resource "aws_security_group" "load_balancer" {
  name        = "${var.namespace}-load-balancer"
  description = "Allow HTTP/HTTPS Traffic From Internet"
  vpc_id      = module.vpc.vpc_id
  tags        = merge(var.tags, { Name = "LoadBalancer" })

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "6"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow incoming HTTP traffic from the Internet"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "6"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow incoming HTTPS traffic from the Internet"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow outgoing connections"
  }
}

############################
# Security Group - ECS Tasks
############################
resource "aws_security_group" "ecs_tasks" {
  description = "ECS Tasks traffic rules"
  vpc_id      = module.vpc.vpc_id
  name        = "${var.namespace}-ecs-tasks"
  tags        = merge(var.tags, { Name = "ECSTasks" })
}

#######################################################
# Security Group Rule - Allow incoming traffic from ALB
#######################################################
resource "aws_security_group_rule" "ecs_alb_access" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.load_balancer.id
  description              = "Allow incoming connections from ALB"
  security_group_id        = aws_security_group.ecs_tasks.id
}

######################################################################
# Security Group Rule - Allow internal communication between ECS tasks
######################################################################
resource "aws_security_group_rule" "ecs_internal_access" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.ecs_tasks.id
  description              = "Allow internal communication between ECS tasks"
  security_group_id        = aws_security_group.ecs_tasks.id
}

#################################################################
# Security Group Rule - Allow outgoing connections from ECS tasks
#################################################################
resource "aws_security_group_rule" "ecs_egress_access" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow outgoing connections from ECS tasks"
  security_group_id = aws_security_group.ecs_tasks.id
}

####################################
# Security Groups - Database Traffic
####################################
resource "aws_security_group" "database" {
  name        = "${var.namespace}-database-access"
  description = "Database traffic rules"
  vpc_id      = module.vpc.vpc_id
  tags        = merge(var.tags, { Name = "Database" })
}

###########################################################
# Security Group Rule - Allows ECS Tasks access to database
###########################################################
resource "aws_security_group_rule" "database_ecs_access" {
  type                     = "ingress"
  from_port                = local.database_port
  to_port                  = local.database_port
  protocol                 = "6"
  source_security_group_id = aws_security_group.ecs_tasks.id
  description              = "Allow incoming connections from ECS Tasks"
  security_group_id        = aws_security_group.database.id
}

# TODO This is a CommandSynter limitation and should be addressed
###########################################################################
# Security Group Rule - Allows CommandSynter Deployments access to database
###########################################################################
resource "aws_security_group_rule" "database_command_synter" {
  type                     = "ingress"
  from_port                = local.database_port
  to_port                  = local.database_port
  protocol                 = "6"
  source_security_group_id = aws_default_security_group.this.id
  description              = "Allow incoming connections from CommandSynter Deployment Tasks"
  security_group_id        = aws_security_group.database.id
}

########################################################################################
# Security Group Rule - Allows Public Database Acccess (Used only during provisioning)
########################################################################################
resource "aws_security_group_rule" "database_public_access" {
  count = var.database_publicly_accessible ? 1 : 0

  type              = "ingress"
  from_port         = local.database_port
  to_port           = local.database_port
  protocol          = "6"
  cidr_blocks       = var.database_public_cidrs
  description       = "Allow incoming connections from public networks"
  security_group_id = aws_security_group.database.id
}

################################
# Security Group - Redis Traffic
################################
resource "aws_security_group" "redis" {
  count = var.use_redis ? 1 : 0

  name        = "${var.namespace}-redis-access"
  description = "Redis traffic rules"
  vpc_id      = module.vpc.vpc_id
  tags        = merge(var.tags, { Name = "Redis" })
}

########################################################
# Security Group Rule - Allows ECS Tasks access to Redis
########################################################
resource "aws_security_group_rule" "redis_ecs_access" {
  count = var.use_redis ? 1 : 0

  type                     = "ingress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "6"
  source_security_group_id = aws_security_group.ecs_tasks.id
  description              = "Allow incoming connections from ECS Tasks"
  security_group_id        = aws_security_group.redis[0].id
}

# TODO This is a CommandSynter limitation and should be addressed
#############################################################################
# Security Group Rule - Allows CommandSynter Deployment Tasks access to Redis
#############################################################################
resource "aws_security_group_rule" "redis_command_synter" {
  count = var.use_redis ? 1 : 0

  type                     = "ingress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "6"
  source_security_group_id = aws_default_security_group.this.id
  description              = "Allow incoming connections from CommandSynter Deployment Tasks"
  security_group_id        = aws_security_group.redis[0].id
}

########################################
# Security Group - ElasticSearch Traffic
########################################
resource "aws_security_group" "elasticsearch" {
  count = var.use_elasticsearch ? 1 : 0

  name        = "${var.namespace}-elasticsearch-access"
  description = "ElasticSearch traffic rules"
  vpc_id      = module.vpc.vpc_id
  tags        = merge(var.tags, { Name = "ElasticSearch" })
}

#####################################################################
# Security Group Rule - Allow outgoing connections from ElasticSearch
#####################################################################
resource "aws_security_group_rule" "elasticsearch_egress_access" {
  count = var.use_elasticsearch ? 1 : 0

  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow outgoing connections from ElasticSearch"
  security_group_id = aws_security_group.elasticsearch[0].id
}

#####################################################################
# Security Group Rule - Allows ElasticSearch Node to Node connections
#####################################################################
resource "aws_security_group_rule" "elasticsearch_node_access" {
  count = var.use_elasticsearch ? 1 : 0

  type                     = "ingress"
  from_port                = 9300
  to_port                  = 9300
  protocol                 = "6"
  source_security_group_id = aws_security_group.elasticsearch[0].id
  description              = "Allow incoming connections from ECS Tasks"
  security_group_id        = aws_security_group.elasticsearch[0].id
}

################################################################
# Security Group Rule - Allows ECS Tasks access to ElasticSearch
################################################################
resource "aws_security_group_rule" "elasticsearch_ecs_access" {
  count = var.use_elasticsearch ? length(local.es_ports) : 0

  type                     = "ingress"
  from_port                = local.es_ports[count.index]
  to_port                  = local.es_ports[count.index]
  protocol                 = "6"
  source_security_group_id = aws_security_group.ecs_tasks.id
  description              = "Allow incoming connections from ECS Tasks"
  security_group_id        = aws_security_group.elasticsearch[0].id
}

# TODO This is a CommandSynter limitation and should be addressed
#####################################################################################
# Security Group Rule - Allows CommandSynter Deployment Tasks access to ElasticSearch
#####################################################################################
resource "aws_security_group_rule" "elasticsearch_command_synter" {
  count = var.use_elasticsearch ? length(local.es_ports) : 0

  type                     = "ingress"
  from_port                = local.es_ports[count.index]
  to_port                  = local.es_ports[count.index]
  protocol                 = "6"
  source_security_group_id = aws_default_security_group.this.id
  description              = "Allow incoming connections from CommandSynter Deployment Tasks"
  security_group_id        = aws_security_group.elasticsearch[0].id
}
