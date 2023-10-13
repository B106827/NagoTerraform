# ---------------------------
# 変数定義
# ---------------------------
locals {
  # サービス
  service_task_desired_count = 0
  service_launch_type        = "FARGATE"
  service_assign_public_ip   = false

  # タスク
  task_cpu    = 256 # 0.25vCPU
  task_memory = 512
  # タスク > コンテナ定義
  ecr_base_url = "${data.aws_caller_identity.self.account_id}.dkr.ecr.${local.region}.amazonaws.com"
}

# ---------------------------
# ECS
# ---------------------------
# クラスター
resource "aws_ecs_cluster" "app-cluster" {
  name = "${local.project_name_env}-cluster"
  tags = {
    Name = "${local.project_name_env}-cluster"
  }
}
# サービス
resource "aws_ecs_service" "app-service" {
  name    = "${local.project_name_env}-service"
  cluster = aws_ecs_cluster.app-cluster.id
  # コンピューティング設定
  launch_type = local.service_launch_type
  # タスク設定
  task_definition = aws_ecs_task_definition.app-task.arn
  desired_count   = local.service_task_desired_count
  # ネットワーク設定
  network_configuration {
    subnets = module.vpc.private_subnets
    security_groups = [
      aws_security_group.alb_sg.id,
      aws_security_group.app_sg.id,
    ]
    assign_public_ip = local.service_assign_public_ip
  }
  # ロードバランサー設定
  load_balancer {
    target_group_arn = aws_lb_target_group.alb_tg_nginx.arn
    container_name   = "${local.project_name_env}-nginx-container"
    container_port   = 80
  }
}
# タスク定義
resource "aws_ecs_task_definition" "app-task" {
  family                   = "${local.project_name_env}-app-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  execution_role_arn       = aws_iam_role.ecs_task_execute_role.arn
  cpu                      = local.task_cpu
  memory                   = local.task_memory
  container_definitions    = local.task_container_definitions
}
# 上記タスクのコンテナ定義
locals {
  task_container_definitions = <<EOF
[
  {
    "name": "${local.project_name_env}-nginx-container",
    "image": "${local.ecr_base_url}/${local.project_name_env}/nginx:latest",
    "privileged": false,
    "essential": true,
    "network_mode": "awsvpc",
    "stopTimeout": 60,
    "ulimits": [
      {
        "name": "nofile", "softLimit": 65536, "hardLimit": 65536
      }
    ],
    "portMappings": [
      { "containerPort": 80 },
      { "containerPort": 443 }
    ],
    "secrets": [],
    "dockerLabels": {},
    "environment": [],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${local.project_name_env}-nginx-log-group",
        "awslogs-region": "${local.region}",
        "awslogs-stream-prefix": "nginx"
      }
    }
  },
  {
    "name": "${local.project_name_env}-api-container",
    "image": "${local.ecr_base_url}/${local.project_name_env}/api:latest",
    "privileged": false,
    "essential": true,
    "network_mode": "awsvpc",
    "stopTimeout": 60,
    "ulimits": [
      {
        "name": "nofile",
        "softLimit": 65536,
        "hardLimit": 65536
      }
    ],
    "portMappings": [
      { "containerPort": 8081 }
    ],
    "secrets": [],
    "dockerLabels": {},
    "environment": [],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${local.project_name_env}-api-log-group",
        "awslogs-region": "${local.region}",
        "awslogs-stream-prefix": "api"
      }
    }
  }
]
EOF
}