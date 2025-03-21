output "ecs_cluster_arn" {
  value = aws_ecs_cluster.main.arn
}

output "ecs_task_execution_role_arn" {
  value = aws_iam_role.ecs_task_execution_role.arn
}

output "ecs_task_run_role_arn" {
  value = aws_iam_role.ecs_task_run_role.arn
}

