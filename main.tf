# ################################################################################
# # VPC Module
# ################################################################################

module "vpc" {
  source      = "./modules/vpc"
  main-region = var.main-region
}

# ################################################################################
# # EKS Cluster Module
# ################################################################################

module "eks" {
  source = "./modules/eks-cluster"

  rolearn = var.rolearn

  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
}

# ################################################################################
# # AWS ALB Controller
# ################################################################################

module "aws_alb_controller" {
  source = "./modules/aws-alb-controller"

  main-region  = var.main-region
  env_name     = var.env_name
  cluster_name = var.cluster_name

  vpc_id            = module.vpc.vpc_id
  oidc_provider_arn = module.eks.oidc_provider_arn
}

# ################################################################################
# # Managed Grafana Module
# ################################################################################

# module "managed_grafana" {
#   source             = "./modules/grafana"
#   env_name           = var.env_name
#   main-region        = var.main-region
#   private_subnets    = module.vpc.private_subnets
#   sso_admin_group_id = var.sso_admin_group_id
# }



# # ################################################################################
# # # Managed Prometheus Module
# # ################################################################################

# module "prometheus" {
#   source            = "./modules/prometheus"
#   env_name          = var.env_name
#   main-region       = var.main-region
#   cluster_name      = var.cluster_name
#   oidc_provider_arn = module.eks.oidc_provider_arn
#   vpc_id            = module.vpc.vpc_id
#   private_subnets   = module.vpc.private_subnets
# }



# # ################################################################################
# # # VPC Endpoints for Prometheus and Grafana Module
# # ################################################################################

# module "vpcendpoints" {
#   source                    = "./modules/vpcendpoints"
#   env_name                  = var.env_name
#   main-region               = var.main-region
#   vpc_id                    = module.vpc.vpc_id
#   private_subnets           = module.vpc.private_subnets
#   grafana_security_group_id = module.managed_grafana.security_group_id
# }


module "jenkins_server" {
  source        = "./modules/jenkins-server"
  ami_id        = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  main-region   = var.main-region
}

module "terraform_node" {
  source        = "./modules/terraform_node"
  ami_id        = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  main-region   = var.main-region
}

module "maven-sonarqube-server" {
  source            = "./modules/maven-sonarqube-server"
  ami_id            = var.ami_id
  instance_type     = var.instance_type
  key_name          = var.key_name
  security_group_id = var.security_group_id
  subnet_id         = var.subnet_id
  # main-region   = var.main-region

  #   db_name              = var.db_name
  #   db_username          = var.db_username
  #   db_password          = var.db_password
  #   db_subnet_group      = var.db_subnet_group
  #   db_security_group_id = var.db_security_group_id
}

# # module "s3_dynamodb" {
# #   source = "./modules/s3-dynamodb"
# #   bucket = var.s3_bucket
# #   table  = var.dynamodb_table
# #   region = var.main-region
# # }
