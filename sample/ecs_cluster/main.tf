###########################################
######### ECS Cluster Module ##############
###########################################

module "ecs_cluster_functionality" {
  source = "../../"

  providers = {
    aws.project = aws.principal              #Write manually alias (the same alias name configured in providers.tf)
  }

  # Common configuration
  client      = var.client
  project     = var.project
  environment = var.environment

  # ECS Cluster configuration
  cluster_config = {
    "app01" = {
      containerInsights       = "enabled"
      enableCapacityProviders = true
      additional_tags         = {
        service-tier = "standard"
        backup-policy = "daily"
      }
    }
  }
}
