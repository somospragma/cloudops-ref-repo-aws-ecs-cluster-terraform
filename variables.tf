###########################################
########## Common variables ###############
###########################################

variable "environment" {
  type        = string
  description = "Environment where resources will be deployed (e.g., dev, qa, prod)"
  
  validation {
    condition     = contains(["dev", "qa", "stg", "prod"], var.environment)
    error_message = "Environment must be one of: dev, qa, stg, prod."
  }
}

variable "client" {
  type        = string
  description = "Client name for resource naming and tagging"
  
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.client))
    error_message = "Client name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "project" {
  type        = string
  description = "Project name for resource naming and tagging"
  
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}

###########################################
######## ECS Cluster variables ############
###########################################

variable "cluster_config" {
  type = map(object({
    containerInsights       = string
    enableCapacityProviders = bool
    additional_tags         = optional(map(string), {})
  }))
  description = <<EOF
    Mapa de configuraciones de clusters ECS donde la clave es el nombre de la aplicación.
    
    Ejemplo:
    ```
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
    ```
    
    Parámetros:
    - containerInsights: (string) Value to assign to the setting. Valid values: enabled, disabled.
    - enableCapacityProviders: (bool) If true, is enabled FARGATE and FARGATE_SPOT.
    - additional_tags: (map) Additional tags to apply to the ECS cluster.
  EOF

  validation {
    condition = alltrue([
      for k, config in var.cluster_config :
      contains(["enabled", "disabled"], config.containerInsights)
    ])
    error_message = "containerInsights must be either 'enabled' or 'disabled'."
  }
  
  validation {
    condition = alltrue([
      for k, _ in var.cluster_config :
      can(regex("^[a-z0-9-]+$", k))
    ])
    error_message = "Application names (keys in cluster_config) must contain only lowercase letters, numbers, and hyphens."
  }
}
