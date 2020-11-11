resource "aws_ecs_cluster" "this" {
    name = var.cluster_name

    capacity_providers = ["FARGATE_SPOT", "FARGATE"]

    default_capacity_provider_strategy {
        capacity_provider = "FARGATE_SPOT"
    }
}
