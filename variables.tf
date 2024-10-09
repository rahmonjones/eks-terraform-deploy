
################################################################################
# Default Variables
################################################################################

variable "main-region" {
  type    = string
  default = "us-west-2"
}


################################################################################
# EKS Cluster Variables
################################################################################

variable "cluster_name" {
  type    = string
  default = "dominion-cluster"
}

variable "rolearn" {
  description = "Add admin role to the aws-auth configmap"
  default     = "arn:aws:iam::322266404742:role/terraform-create-role"
}

################################################################################
# ALB Controller Variables
################################################################################

variable "env_name" {
  type    = string
  default = "dev"
}

################################################################################
# EKS Cluster Variables for grafana and prometheus deployment
################################################################################

# variable "cluster_endpoint" {
#   type        = string
#   sensitive   = true
#   description = "The cluster endpoint"
# }

# variable "cluster_certificate_authority_data" {
#   type        = string
#   sensitive   = true
#   description = "The Cluster certificate data"
# }

# variable "oidc_provider_arn" {
#   description = "OIDC Provider ARN used for IRSA "
#   type        = string
#   sensitive   = true
# }

################################################################################
# VPC Variables
################################################################################

# variable "vpc_id" {
#   description = "VPC ID which Load balancers will be  deployed in"
#   type        = string
# }

# variable "private_subnets" {
#   description = "A list of private subnets"
#   type        = list(string)
# }

################################################################################
# AWS SSO Variables
################################################################################

variable "sso_admin_group_id" {
  description = "AWS_SSO Admin Group ID"
  type        = string
  sensitive   = true
  default     = "b4f8f4f8-e011-7046-0637-993dc10edd76"
}

variable "ami_id" {
  description = "The AMI ID for the instances"
  type        = string
  default     = "ami-079c0d2990b4033f4"
}

variable "instance_type" {
  description = "The instance type for the instances"
  type        = string
  default     = "t2.large"
}


variable "key_name" {
  description = "The key name for the instances"
  type        = string
  default     = "DevOps_Train2024"
}

###########################
#Sonaqube instance
##########################
variable "security_group_id" {
  type    = string
  default = "sg-07b8b3043804ede33"
}

# variable "subnet_id" {
#   type    = string
#   default = "subnet-036b6ddb502f8eb8a"
# }

# variable "security_group_id" {
#   description = "The security group ID to attach to the instance"
#   type        = string

# }
##################
#sonarqube db 
###################
# variable "subnet_id" {
#   description = "The subnet ID where the instance will be deployed"
#   type        = string
#   default     = "subnet-0ea3d234fba84eef9"
# }

# variable "db_name" {
#   description = "The name of the PostgreSQL database"
#   type        = string
#   default     = "sonarqube"
# }

# variable "db_username" {
#   description = "The username for the PostgreSQL database"
#   type        = string
#   default     = "sonar"
# }

# variable "db_password" {
#   description = "The password for the PostgreSQL database"
#   type        = string
#   sensitive   = true
#   default     = "Team@123"
# }

# variable "db_security_group_id" {
#   description = "The security group ID for the PostgreSQL database"
#   type        = list(string)
#   default     = ["sg-0f424207f7b50b172"]
# }

# variable "db_subnet_group" {
#   description = "The subnet group for the PostgreSQL database"
#   type        = string
#   default     = "default-vpc-08dcf780b5e752f2c"
# }

# variable "s3_bucket" {
#   description = "The name of the S3 bucket for storing Terraform state"
#   type        = string
#   default     = "terraform-state-bucket-fusi"
# }

# variable "dynamodb_table" {
#   description = "The name of the DynamoDB table for state locking"
#   type        = string
#   default     = "terraform-lock-table"
# }
