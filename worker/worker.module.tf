resource "aws_ecs_task_definition" "definition" {
  family                   = "project-${var.worker_name}-${var.env.envName}"
  execution_role_arn       = var.security.app_execution_role_arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  container_definitions    = var.rendered_definition
  task_role_arn            = var.security.app_main_role_arn
}

resource "aws_ecs_service" "service" {
  name                              = "project-${var.worker_name}-service-${var.env.envName}"
  cluster                           = var.cluster.id
  task_definition                   = aws_ecs_task_definition.definition.arn
  desired_count                     = var.desire_count
  enable_execute_command            = true

  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    base              = 1
    weight            = 100
  }

  network_configuration {
    security_groups  = [var.security.esc_sg_id]
    subnets          = var.private_networks.*.id
    assign_public_ip = true
  }
}

resource "aws_appautoscaling_target" "autoscaletarget" {
  service_namespace  = "ecs"
  resource_id        = "service/${var.cluster.name}/${aws_ecs_service.service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = var.autoscale_min_instances_count
  max_capacity       = var.autoscale_max_instances_count
}

resource "aws_appautoscaling_policy" "scale_up" {
  name               = "sqs-auto-scaling-up-${var.worker_name}-${var.env.envName}"
  service_namespace  = "ecs"
  scalable_dimension = "ecs:service:DesiredCount"
  resource_id        = aws_appautoscaling_target.autoscaletarget.resource_id

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = var.autoscale_up_policy_cooldown
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }

  depends_on = [aws_appautoscaling_target.autoscaletarget]
}

resource "aws_appautoscaling_policy" "scale_down" {
  name               = "sqs-auto-scaling-down-${var.worker_name}-${var.env.envName}"
  service_namespace  = "ecs"
  scalable_dimension = "ecs:service:DesiredCount"
  resource_id        = aws_appautoscaling_target.autoscaletarget.resource_id

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = var.autoscale_down_policy_cooldown
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = -1
    }
  }

  depends_on = [aws_appautoscaling_target.autoscaletarget]
}

# Cloudwatch alarm that triggers the autoscaling up policy
resource "aws_cloudwatch_metric_alarm" "sqs_messages_up" {
  alarm_name          = "${var.env.envName}-${var.worker_name}-project_messages_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = "60"
  statistic           = "Average"
  threshold           = "1"

  dimensions = {
    QueueName = var.queue_name
  }

  alarm_actions = [aws_appautoscaling_policy.scale_up.arn]
}

# Cloudwatch alarm that triggers the autoscaling up policy
resource "aws_cloudwatch_metric_alarm" "sqs_messages_down" {
  alarm_name          = "${var.env.envName}-${var.worker_name}-project_messages_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "10"
  metric_name         = "ApproximateNumberOfMessagesNotVisible"
  namespace           = "AWS/SQS"
  period              = "60"
  statistic           = "Average"
  threshold           = "0"

  dimensions = {
    QueueName = var.queue_name
  }

  alarm_actions = [aws_appautoscaling_policy.scale_down.arn]
}

//add cloudwatch log group
resource "aws_cloudwatch_log_group" "cloudwatch_log_group" {
  name = "ecs/project-${var.worker_name}-${var.env.envName}"
  retention_in_days = 90
}