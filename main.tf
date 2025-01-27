###########################################
####### ECS Cluster Resources #############
###########################################

resource "aws_ecs_cluster" "cluster" {
  provider = aws.project
  for_each = {
    for idx, item in var.cluster_config : item.application => merge(item, {
      index = idx
    })
  }
  name = lower(join("-", [var.client, var.project, var.environment, "cluster", each.key, format("%02d", each.value.index + 1)]))
  setting {
    name  = "containerInsights"
    value = each.value.containerInsights
  }
  tags = {
    Name        = lower(join("-", [var.client, var.project, var.environment, "cluster", each.key, format("%02d", each.value.index + 1)]))
    Application = each.key
  }
}

###########################################
####### ECS Cluster Providers #############
###########################################
resource "aws_ecs_cluster_capacity_providers" "cluster_capacity_providers" {
  provider = aws.project
  for_each = {
    for idx, item in var.cluster_config : item.application => item
    if item.enableCapacityProviders
  }

  cluster_name = aws_ecs_cluster.cluster[each.key].name
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]
  depends_on = [aws_ecs_cluster.cluster]
}