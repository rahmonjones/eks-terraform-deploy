variable "ami_id" {
  description = "The AMI ID for the Terraform node"
  type        = string
  default     = "ami-0b8c6b923777519db"
}

variable "instance_type" {
  description = "The instance type for the Terraform node"
  type        = string
  default     = "t2.large"
}

variable "key_name" {
  description = "The key name for the Terraform node"
  type        = string
}

variable "main-region" {
  description = "The AWS region to deploy resources"
  type        = string
}
