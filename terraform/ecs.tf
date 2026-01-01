resource "aws_ecs_cluster" "fastapi-app" {
  name = "${var.app_name}-cluster"
}

resource "aws_ecs_service" "fastapi-app" {
  name            = "${var.app_name}-service"
  cluster         = aws_ecs_cluster.fastapi-app.id
  task_definition = aws_ecs_task_definition.fastapi-app.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    security_groups  = [aws_security_group.fastapi_ecs_task_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.fastapi-ecs.arn
    container_name   = "fastapi-app"
    container_port   = 8000
  }

  depends_on = [aws_lb.fastapi-ecs]
}

resource "aws_ecs_task_definition" "fastapi-app" {
  family                   = "${var.app_name}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = aws_iam_role.task_execution_role.arn
  container_definitions = jsonencode([
    {
      name      = "fastapi-app"
      image     = aws_ecr_repository.fastapi-ecs.repository_url
      cpu       = var.task_cpu
      memory    = var.task_memory
      essential = true
      portMappings = [
        {
          containerPort = 8000
          hostPort      = 8000
          protocol      = "tcp"
        }
      ]
      healthCheck = {
        command     = ["CMD-SHELL", "wget --no-verbose --tries=1 --spider http://localhost:8000/ || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
      environment = [
        for key, value in var.environment_variables :
        {
          name  = key
          value = value
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.fastapi-app.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "fastapi"
        }
      }
    }
  ])
}
