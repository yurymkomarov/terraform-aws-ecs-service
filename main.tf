locals {
  default_container_definition = {
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-create-group = tostring(true)
        awslogs-group        = "${var.name}-${random_id.this.hex}"
        awslogs-region       = data.aws_region.this.name
      }
    }
  }
}

resource "random_id" "this" {
  byte_length = 1
}

resource "aws_appautoscaling_target" "this" {
  max_capacity       = var.desired_count * 4
  min_capacity       = var.desired_count
  resource_id        = "service/${var.cluster["name"]}/${aws_ecs_service.this.name}"
  role_arn           = data.aws_iam_role.ecs_service.arn
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "cpu" {
  name               = "${var.name}-cpu-${random_id.this.hex}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.this.resource_id
  scalable_dimension = aws_appautoscaling_target.this.scalable_dimension
  service_namespace  = aws_appautoscaling_target.this.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    disable_scale_in   = false
    target_value       = 75
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}

resource "aws_appautoscaling_policy" "ram" {
  name               = "${var.name}-ram-${random_id.this.hex}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.this.resource_id
  scalable_dimension = aws_appautoscaling_target.this.scalable_dimension
  service_namespace  = aws_appautoscaling_target.this.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }

    disable_scale_in   = false
    target_value       = 75
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}

resource "aws_ecs_service" "this" {
  name    = "${var.name}-${random_id.this.hex}"
  cluster = var.cluster["arn"]

  scheduling_strategy = var.scheduling_strategy
  desired_count       = var.scheduling_strategy == "DAEMON" ? 0 : var.desired_count

  deployment_minimum_healthy_percent = 50

  task_definition = aws_ecs_task_definition.this.arn

  dynamic "load_balancer" {
    for_each = var.ecs_task.load_balancer

    content {
      target_group_arn = load_balancer.value["target_group_arn"]
      container_name   = load_balancer.value["container_name"]
      container_port   = load_balancer.value["container_port"]
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_ecs_task_definition" "this" {
  family             = "${var.name}-${random_id.this.hex}"
  network_mode       = var.network_mode
  task_role_arn      = aws_iam_role.ecs_task.arn
  execution_role_arn = aws_iam_role.execution_ecs_task.arn

  container_definitions = jsonencode(flatten([
    for i in var.ecs_task.container_definitions : merge(local.default_container_definition, i)
  ]))

  dynamic volume {
    for_each = var.ecs_task.volumes

    content {
      name      = volume.value["name"]
      host_path = volume.value["host_path"]
    }
  }
}

resource "aws_iam_role" "ecs_task" {
  assume_role_policy = data.aws_iam_policy_document.assume_esc_task.json
  name               = "${var.name}-task-${random_id.this.hex}"
  path               = "/"

  tags = {
    Name      = var.name
    Module    = path.module
    Workspace = terraform.workspace
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy" "ecs_task" {
  name   = "${var.name}-task-${random_id.this.hex}"
  policy = data.aws_iam_policy_document.policy_esc_task.json
  role   = aws_iam_role.ecs_task.id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role" "execution_ecs_task" {
  assume_role_policy = data.aws_iam_policy_document.assume_esc_task.json
  name               = "${var.name}-execution-${random_id.this.hex}"
  path               = "/"

  tags = {
    Name      = var.name
    Module    = path.module
    Workspace = terraform.workspace
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role_policy" "execution_ecs_task" {
  name   = "${var.name}-execution-${random_id.this.hex}"
  policy = data.aws_iam_policy_document.execution_policy_esc_task.json
  role   = aws_iam_role.execution_ecs_task.id

  lifecycle {
    create_before_destroy = true
  }
}
