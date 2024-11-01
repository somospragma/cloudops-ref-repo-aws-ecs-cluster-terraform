resource "aws_ecs_cluster" "cluster" {
  provider = aws.project
  for_each = {
    for item in var.cluster_config : item.application => {
      containerInsights       = item.containerInsights
      enableCapacityProviders = item.enableCapacityProviders
    }
  }

  name = lower(join("-", [var.client, var.project, var.environment, "cluster", each.key]))

  setting {
    name  = "containerInsights"
    value = each.value.containerInsights
  }

  tags = {
    Name        = lower(join("-", [var.client, var.project, var.environment, "cluster", each.key]))
    Application = each.key
  }
}

resource "aws_ecs_cluster_capacity_providers" "cluster_capacity_providers" {
  provider = aws.project
  for_each = {
    for item in var.cluster_config : item.application => item
    if item.enableCapacityProviders
  }

  cluster_name = aws_ecs_cluster.cluster[each.key].name
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]
}