###########################################
########## Common variables ###############
###########################################

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

###########################################
######## ECS Cluster variables ############
###########################################

variable "cluster_config" {
  type = list(object({
    application             = string
    containerInsights       = string
    enableCapacityProviders = bool
  }))
  description = <<EOF
    - application: (string) Application name.
    - containerInsights: (string) Value to assign to the setting. Valid values: enabled, disabled.
    - enableCapacityProviders: (bool) If true, is enabled FARGATE and FARGATE_SPOT.
  EOF

  validation {
    condition = alltrue([
      for config in var.cluster_config :
      contains(["enabled", "disabled"], config.containerInsights)
    ])
    error_message = "containerInsights must be either 'enabled' or 'disabled'."
  }
}
