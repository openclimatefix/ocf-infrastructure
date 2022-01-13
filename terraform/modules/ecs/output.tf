output "ecs_cluster" {
  value = aws_ecs_cluster.main
}

output "ecs_task_execution_role" {
  value = aws_iam_role.ecs_task_execution_role
}
