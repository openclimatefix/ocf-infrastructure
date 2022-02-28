output "prometheus_endpoint_url" {
  value = aws_prometheus_workspace.statusdash.prometheus_endpoint
}
