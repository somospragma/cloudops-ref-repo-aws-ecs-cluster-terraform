###########################################
######### ECS Cluster Module ##############
###########################################

module "ecs_cluster_functionality" {
  source = "../../"

  providers = {
    aws.project = aws.alias01              #Write manually alias (the same alias name configured in providers.tf)
  }

  # Common configuration
  client      = var.client
  project     = var.project
  environment = var.environment

  # ECS Cluster configuration
  cluster_config = [
    {
      application             = var.application
      containerInsights       = "enabled"
      enableCapacityProviders = true
    }
  ]
}