data "aws_region" "current" {}

data "template_file" "project_app" {
  template = file("./templates/app.taskdef.json.tpl")

  vars = merge(
    module.env.APP_SETTINGS,
    module.env.APP_ENVIRONMENT,
    module.env.APP_SECRETS,
    {
      envName: module.env.envName,
      image: var.appImage,
      region: data.aws_region.current.name,
      ADDITIONAL_ENVIRONMENT: "additionalEnvironemnt"
    }
  )
}

resource "aws_ecs_task_definition" "app" {
  family                   = "project-app-${module.env.envName}"
  execution_role_arn       = module.security.app_execution_role_arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = module.env.APP_SETTINGS.INSTANCE_CPU
  memory                   = module.env.APP_SETTINGS.INSTANCE_MEMORY
  container_definitions    = data.template_file.project_app.rendered
  task_role_arn            = module.security.app_main_role_arn
}

resource "aws_ecs_service" "main" {
  name                              = "project-app-service-${module.env.envName}"
  cluster                           = aws_ecs_cluster.Project.id
  task_definition                   = aws_ecs_task_definition.app.arn
  desired_count                     = module.env.APP_SETTINGS.DESIRED_INSTANCE_COUNT
  health_check_grace_period_seconds = 20
  enable_execute_command            = true

  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    base              = 1
    weight            = 100
  }

  network_configuration {
    security_groups  = [module.security.esc_sg_id, module.security.db_sg_id]
    subnets          = aws_subnet.private.*.id
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ingress_to_http.id
    container_name   = "project-app-${module.env.envName}"
    container_port   = 80
  }

  depends_on = [aws_lb_listener.front_end]
}

resource "aws_appautoscaling_target" "app" {
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.Project.name}/${aws_ecs_service.main.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = module.env.APP_SETTINGS.MIN_INSTANCE_COUNT
  max_capacity       = module.env.APP_SETTINGS.MAX_INSTANCE_COUNT
}

resource "aws_appautoscaling_policy" "up" {
  name               = "${module.env.envName}-project_scale_up"
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.Project.name}/${aws_ecs_service.main.name}"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }

  depends_on = [aws_appautoscaling_target.app]
}

# Automatically scale capacity down by one
resource "aws_appautoscaling_policy" "down" {
  name               = "${module.env.envName}-project_scale_down"
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.Project.name}/${aws_ecs_service.main.name}"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = -1
    }
  }

  depends_on = [aws_appautoscaling_target.app]
}

# Cloudwatch alarm that triggers the autoscaling up policy
resource "aws_cloudwatch_metric_alarm" "service_cpu_high" {
  alarm_name          = "${module.env.envName}-project_cpu_utilization_high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "85"

  dimensions = {
    ClusterName = aws_ecs_cluster.Project.name
    ServiceName = aws_ecs_service.main.name
  }

  alarm_actions = [aws_appautoscaling_policy.up.arn]
}

# Cloudwatch alarm that triggers the autoscaling down policy
resource "aws_cloudwatch_metric_alarm" "service_cpu_low" {
  alarm_name          = "${module.env.envName}-project_cpu_utilization_low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "10"

  dimensions = {
    ClusterName = aws_ecs_cluster.Project.name
    ServiceName = aws_ecs_service.main.name
  }

  alarm_actions = [aws_appautoscaling_policy.down.arn]
}

//add cloudwatch log group
resource "aws_cloudwatch_log_group" "app_logs" {
  name = "ecs/project-app-${module.env.envName}"
  retention_in_days = 90
}