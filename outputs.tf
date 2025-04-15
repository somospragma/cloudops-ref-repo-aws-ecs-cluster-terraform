output "cluster_info" {
  value = {
    for key, cluster in aws_ecs_cluster.cluster : key => {
      cluster_name   = cluster.name
      cluster_arn    = cluster.arn
      cluster_id     = cluster.id
      application    = key
    }
  }
  description = "Map of cluster information keyed by application name"
}
