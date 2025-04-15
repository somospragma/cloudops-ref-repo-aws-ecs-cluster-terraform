###########################################
####### ECS Cluster Resources #############
###########################################
resource "aws_ecs_cluster" "cluster" {
  provider = aws.project
  for_each = var.cluster_config
  
  name = local.cluster_names[each.key]
  
  setting {
    name  = "containerInsights"
    value = each.value.containerInsights
  }
  
  tags = merge(
    {
      Name        = local.cluster_names[each.key]
      Application = each.key
    },
    each.value.additional_tags
  )
}

###########################################
####### ECS Cluster Providers #############
###########################################
resource "aws_ecs_cluster_capacity_providers" "cluster_capacity_providers" {
  provider = aws.project
  for_each = {
    for app_name, config in var.cluster_config : app_name => config
    if config.enableCapacityProviders
  }

  cluster_name = aws_ecs_cluster.cluster[each.key].name
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]
  depends_on = [aws_ecs_cluster.cluster]
}
