variable "cluster_config" {
  type = list(object({
    application             = string
    containerInsights       = string
    enableCapacityProviders = bool
  }))

  validation {
    condition = alltrue([
      for config in var.cluster_config :
      contains(["enabled", "disabled"], config.containerInsights)
    ])
    error_message = "containerInsights must be either 'enabled' or 'disabled'."
  }
}

variable "client" {
  type = string
}

variable "environment" {
  type = string
}

variable "project" {
  description = "Nombre del Proyecto"
  type        = string
}
