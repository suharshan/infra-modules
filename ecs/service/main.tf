data "aws_iam_policy_document" "ecs_tasks" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_execution" {
  name               = "${var.name}-ecs_task_execution"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks.json

}

# module "service_container_definition" {
#   source  = "cloudposse/ecs-container-definition/aws"
#   version = "v0.40.0"

#   container_name  = var.name
#   container_image = var.image

#   container_cpu                = var.ecs_task_cpu
#   container_memory             = var.ecs_task_memory
#   container_memory_reservation = var.container_memory_reservation

#   user                     = var.user
#   ulimits                  = var.ulimits
#   entrypoint               = var.entrypoint
#   command                  = var.command
#   working_directory        = var.working_directory

#   port_mappings = [
#     {
#       containerPort = var.port
#       hostPort      = var.port
#       protocol      = "tcp"
#     },
#   ]

#   log_configuration = {
#     logDriver = "awslogs"
#     options = {
#       awslogs-region        = data.aws_region.current.name
#       awslogs-group         = aws_cloudwatch_log_group.this.name
#       awslogs-stream-prefix = "ecs"
#     }
#     secretOptions = []
#   }
# }

resource "aws_ecs_task_definition" "service" {
  family                = var.name
  network_mode = "awsvpc"
  requires_compatibilities = [
    "FARGATE"
  ]
  cpu = 256
  memory = 512

  container_definitions = <<-EOF
  [
    {
      "name": "${var.container_name}",
      "image": "nginx:1.17.7-alpine",
      "cpu": 256,
      "memory": 512,
      "essential": true,
      "portMappings": [
        {
          "containerPort": ${var.container_port},
          "protocol": "tcp"
        }
      ],
      "command": [
        "/bin/sh",
        "-c",
        "echo \"server { listen ${var.container_port}; location /{return 200 'ok';}}\" > etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"
      ]
    }
  ]
  EOF
}

module "ecs_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "v3.16.0"

  name        = "${var.name}-service-${var.environment}"
  # vpc_id      = local.vpc_id
  vpc_id = var.vpc_id
  description = "Security group with open port for ${var.name} (${var.container_port}) from ALB, egress ports are all world open"

  ingress_with_source_security_group_id = [
    {
      from_port                = var.container_port
      to_port                  = var.container_port
      protocol                 = "tcp"
      description              = var.name
      source_security_group_id = var.alb_security_group_id
      # source_security_group_id = local.alb_security_group_id
    },
  ]

  egress_rules = ["all-all"]

}

resource "aws_ecs_service" "this" {
  name    = var.name
  cluster = var.cluster_id
  task_definition = aws_ecs_task_definition.service.id
  desired_count                      = var.ecs_service_desired_count
  launch_type                        = "FARGATE"
  deployment_maximum_percent         = var.ecs_service_deployment_maximum_percent
  deployment_minimum_healthy_percent = var.ecs_service_deployment_minimum_healthy_percent

  network_configuration {
    # subnets          = local.private_subnet_ids
    subnets          = var.private_subnet_ids
    security_groups  = [module.ecs_sg.this_security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    container_name   = var.name
    container_port   = var.container_port
    target_group_arn = var.target_group_arn
  }
}

# module "ecr" {
#   source = "../../ecr"

#   ecr_name = var.name
# }


# resource "aws_ecr_repository" "this" {
#   name                 = var.name

#   image_scanning_configuration {
#     scan_on_push = true
#   }
# }

resource "aws_cloudwatch_log_group" "this" {
  name              = var.name
  retention_in_days = var.cloudwatch_log_retention_in_days

}
