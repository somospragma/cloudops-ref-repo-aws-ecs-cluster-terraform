###########################################
########## Common variables ###############
###########################################

variable "profile" {
  type = string
  description = "Profile name containing the access credentials to deploy the infrastructure on AWS"
}

variable "common_tags" {
    type = map(string)
    description = "Common tags to be applied to the resources"
}

variable "aws_region" {
  type = string
  description = "AWS region where resources will be deployed"
}

variable "environment" {
  type = string
  description = "Environment where resources will be deployed"
}

variable "client" {
  type = string
  description = "Client name"
}

variable "project" {
  type = string  
  description = "Project name"
}