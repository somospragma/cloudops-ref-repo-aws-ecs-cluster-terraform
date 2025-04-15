
locals {
  # Simplificación de la generación de nombres de clusters
  cluster_names = {
    for app_name, _ in var.cluster_config : app_name => 
      lower("${var.client}-${var.project}-${var.environment}-cluster-${app_name}")
  }
}