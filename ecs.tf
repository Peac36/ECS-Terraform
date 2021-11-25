resource "aws_ecs_cluster" "Project" {
  name = "Project-${module.env.envName}"
  capacity_providers = ["FARGATE_SPOT", "FARGATE"]
  default_capacity_provider_strategy {
      capacity_provider = "FARGATE_SPOT"
      weight = 100
      base = 1
  }
}