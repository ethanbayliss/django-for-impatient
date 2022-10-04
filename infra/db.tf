# ################################################################################
# # PostgreSQL Serverless v2
# ################################################################################

# data "aws_rds_engine_version" "postgresql" {
#   engine  = "aurora-postgresql"
#   version = "14.3"
# }

# module "aurora_postgresql_v2" {
#   source  = "terraform-aws-modules/rds-aurora/aws"
#   version = "7.5.1"

#   name              = "${local.name}-postgresqlv2"
#   engine            = data.aws_rds_engine_version.postgresql.engine
#   engine_mode       = "serverless"
#   engine_version    = data.aws_rds_engine_version.postgresql.version
#   storage_encrypted = true

#   vpc_id                = module.vpc.vpc_id
#   subnets               = module.vpc.database_subnets
#   create_security_group = true
#   allowed_cidr_blocks   = module.vpc.private_subnets_cidr_blocks

#   monitoring_interval = 60

#   apply_immediately   = true
#   skip_final_snapshot = true

#   db_parameter_group_name         = aws_db_parameter_group.postgresql.id
#   db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.postgresql.id

#   serverlessv2_scaling_configuration = {
#     min_capacity = 2
#     max_capacity = 10
#   }

#   instance_class = "db.serverless"
#   instances = {
#     one = {}
#     two = {}
#   }
# }

# resource "aws_db_parameter_group" "postgresql" {
#   name        = "${local.name}-aurora-db-postgres14-parameter-group"
#   family      = "aurora-postgresql14"
#   description = "${local.name}-aurora-db-postgres14-parameter-group"
#   tags        = local.tags
# }

# resource "aws_rds_cluster_parameter_group" "postgresql" {
#   name        = "${local.name}-aurora-postgres14-cluster-parameter-group"
#   family      = "aurora-postgresql14"
#   description = "${local.name}-aurora-postgres14-cluster-parameter-group"
#   tags        = local.tags
# }
