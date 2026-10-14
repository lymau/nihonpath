# --- ECS Cluster ---

resource "aws_ecs_cluster" "main" {
  name = "${var.name_prefix}-${var.environment}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = merge(var.tags, {
    Name        = "${var.name_prefix}-${var.environment}-cluster"
    Environment = var.environment
  })
}

# --- CloudWatch Logs ---

resource "aws_cloudwatch_log_group" "api" {
  name              = "/ecs/${var.name_prefix}-${var.environment}-api"
  retention_in_days = var.log_retention_in_days

  tags = merge(var.tags, {
    Name        = "${var.name_prefix}-${var.environment}-api-logs"
    Environment = var.environment
  })
}

resource "aws_cloudwatch_log_group" "worker" {
  name              = "/ecs/${var.name_prefix}-${var.environment}-worker"
  retention_in_days = var.log_retention_in_days

  tags = merge(var.tags, {
    Name        = "${var.name_prefix}-${var.environment}-worker-logs"
    Environment = var.environment
  })
}

# --- IAM Roles (Least Privilege §12.1) ---

data "aws_iam_policy_document" "ecs_tasks_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "task_execution" {
  name               = "${var.name_prefix}-${var.environment}-ecs-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role.json

  tags = merge(var.tags, {
    Name        = "${var.name_prefix}-${var.environment}-ecs-task-execution-role"
    Environment = var.environment
  })
}

resource "aws_iam_role_policy_attachment" "task_execution" {
  role       = aws_iam_role.task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "api_task" {
  name               = "${var.name_prefix}-${var.environment}-api-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role.json

  tags = merge(var.tags, {
    Name        = "${var.name_prefix}-${var.environment}-api-task-role"
    Environment = var.environment
  })
}

resource "aws_iam_role" "worker_task" {
  name               = "${var.name_prefix}-${var.environment}-worker-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role.json

  tags = merge(var.tags, {
    Name        = "${var.name_prefix}-${var.environment}-worker-task-role"
    Environment = var.environment
  })
}

# --- Application Load Balancer ---

resource "aws_lb" "api" {
  name               = "${var.name_prefix}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false

  tags = merge(var.tags, {
    Name        = "${var.name_prefix}-${var.environment}-alb"
    Environment = var.environment
  })
}

resource "aws_lb_target_group" "api" {
  name        = "${var.name_prefix}-${var.environment}-api-tg"
  port        = var.api_container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    path                = "/healthz"
    port                = tostring(var.api_container_port)
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = merge(var.tags, {
    Name        = "${var.name_prefix}-${var.environment}-api-tg"
    Environment = var.environment
  })
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.api.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }
}

# --- API Container Service & Task Definition ---

resource "aws_ecs_task_definition" "api" {
  family                   = "${var.name_prefix}-${var.environment}-api"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = tostring(var.api_cpu)
  memory                   = tostring(var.api_memory)
  execution_role_arn       = aws_iam_role.task_execution.arn
  task_role_arn            = aws_iam_role.api_task.arn

  container_definitions = jsonencode([
    {
      name      = "api"
      image     = var.api_image
      essential = true
      portMappings = [
        {
          containerPort = var.api_container_port
          hostPort      = var.api_container_port
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.api.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "api"
        }
      }
      environment = var.api_environment_variables
    }
  ])

  tags = merge(var.tags, {
    Name        = "${var.name_prefix}-${var.environment}-api-td"
    Environment = var.environment
  })
}

resource "aws_ecs_service" "api" {
  name            = "${var.name_prefix}-${var.environment}-api"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.api.arn
  desired_count   = var.api_min_capacity
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.api_security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.api.arn
    container_name   = "api"
    container_port   = var.api_container_port
  }

  lifecycle {
    ignore_changes = [desired_count]
  }

  tags = merge(var.tags, {
    Name        = "${var.name_prefix}-${var.environment}-api-service"
    Environment = var.environment
  })

  depends_on = [aws_lb_listener.http]
}

# --- API Autoscaling (CPU 60% §11.2) ---

resource "aws_appautoscaling_target" "api" {
  max_capacity       = var.api_max_capacity
  min_capacity       = var.api_min_capacity
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.api.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "api_cpu" {
  name               = "${var.name_prefix}-${var.environment}-api-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.api.resource_id
  scalable_dimension = aws_appautoscaling_target.api.scalable_dimension
  service_namespace  = aws_appautoscaling_target.api.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = var.api_target_cpu_utilization
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}

# --- Worker Container Service & Task Definition (1 BullMQ Worker) ---

resource "aws_ecs_task_definition" "worker" {
  family                   = "${var.name_prefix}-${var.environment}-worker"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = tostring(var.worker_cpu)
  memory                   = tostring(var.worker_memory)
  execution_role_arn       = aws_iam_role.task_execution.arn
  task_role_arn            = aws_iam_role.worker_task.arn

  container_definitions = jsonencode([
    {
      name      = "worker"
      image     = var.worker_image
      essential = true
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.worker.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "worker"
        }
      }
      environment = var.worker_environment_variables
    }
  ])

  tags = merge(var.tags, {
    Name        = "${var.name_prefix}-${var.environment}-worker-td"
    Environment = var.environment
  })
}

resource "aws_ecs_service" "worker" {
  name            = "${var.name_prefix}-${var.environment}-worker"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.worker.arn
  desired_count   = var.worker_desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.worker_security_group_id]
    assign_public_ip = false
  }

  tags = merge(var.tags, {
    Name        = "${var.name_prefix}-${var.environment}-worker-service"
    Environment = var.environment
  })
}
