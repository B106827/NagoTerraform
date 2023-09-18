# ---------------------------
# 変数定義
# ---------------------------
locals {
  task_desired_count       = 0
  service_launch_type      = "FARGATE"
  service_assign_public_ip = false

  task_app_cpu    = 256 # 0.25vCPU
  task_app_memory = 512
}

# ---------------------------
# ECS
# ---------------------------
# クラスター
resource "aws_ecs_cluster" "cluster" {
  name = "${local.project_name_env}-cluster"
  tags = {
    Name = "${local.project_name_env}-cluster"
  }
}
# サービス
resouce "aws_ecs_service" "service" {
  name    = "${local.project_name_env}-service"
  cluster = aws_ecs_cluster.cluster.id
  # コンピューティング設定
  launch_type = locals.service_launch_type
  # タスク設定
  task_definition = aws_ecs_task_definition.task.arn
  desired_count   = locals.task_desired_count
  # ネットワーク設定
  network_configuration {
    subnets = module.vpc.private_subnets
    security_groups = [
      aws_security_group.alb-sg.id,
      aws_security_group.app-sg.id,
    ]
    assign_public_ip = locals.service_assign_public_ip
  }
  # ロードバランサー設定
  load_balancer {
    target_group_arn = aws_lb_target_group.alb-tg-app.arn
    container_name   = "${local.project_name_env}-nginx-container"
    container_port   = 80
  }
}
# タスク定義
resource "aws_ecs_task_definition" "app" {
  family                   = "${local.project_name_env}-app-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = local.task_app_cpu
  memory                   = local.task_app_memory
  container_definitions    = local.task_app_container_definitions
}
# 上記タスク定義のコンテナ定義
locals {
  task_app_container_definitions = <<EOF
[
  {
    "name": ""
  }
]
EOF
}