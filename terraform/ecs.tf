resource "aws_ecs_cluster" "sre" {
  name = "sre-portfolio-tf-cluster"

  tags = {
    Name = "sre-portfolio-tf-cluster"
  }
}
resource "aws_ecs_task_definition" "sre_api" {
  family                   = "sre-portfolio-tf-task"
  requires_compatibilities = ["FARGATE"]

  network_mode = "awsvpc"

  cpu    = "256"
  memory = "512"

  execution_role_arn = aws_iam_role.ecs_task_execution.arn

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }

  container_definitions = jsonencode([
    {
      name      = "sre-api"
      image     = "${data.aws_ecr_repository.sre.repository_url}:latest"
      essential = true

      portMappings = [
        {
          containerPort = 8000
          hostPort      = 8000
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          awslogs-group         = aws_cloudwatch_log_group.sre_api.name
          awslogs-region        = "ap-northeast-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  tags = {
    Name = "sre-portfolio-tf-task"
  }
}

resource "aws_ecs_service" "sre_api" {
  name            = "sre-portfolio-tf-service"
  cluster         = aws_ecs_cluster.sre.id
  task_definition = aws_ecs_task_definition.sre_api.arn

  desired_count = 1
  launch_type   = "FARGATE"

  network_configuration {
    subnets = data.aws_subnets.default.ids

    security_groups = [
      aws_security_group.sre_api.id
    ]

    assign_public_ip = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.ecs_task_execution
  ]

  tags = {
    Name = "sre-portfolio-tf-service"
  }

  # 既存設定...
  lifecycle {
    ignore_changes = [
      task_definition
    ]
  }
}
