# --- Lambda ---

resource "aws_cloudwatch_log_group" "api" {
  name              = "/aws/lambda/${var.app_name}-api"
  retention_in_days = 14
}

resource "aws_lambda_function" "api" {
  function_name    = "${var.app_name}-api"
  role             = aws_iam_role.lambda.arn
  image_uri        = "${var.container-registry}/${var.container-name}:${var.container-tag}"
  package_type     = "Image"
  timeout          = 10

  environment {
    variables = {}
  }

  tags = {
    name = "${var.app_name}"
    type = "lambda"
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.api,
  ]
}

resource "aws_lambda_provisioned_concurrency_config" "lambda_concurrentl_limit" {
  function_name                     = aws_lambda_alias.api.function_name
  provisioned_concurrent_executions = 1
  qualifier                         = aws_lambda_alias.api.name
}


# --- Lambda Endpoint ---

resource "aws_lambda_function_url" "api" {
  function_name      = aws_lambda_function.api.function_name
  authorization_type = "NONE"

  cors {
    allow_credentials = true
    allow_origins     = ["*"]
    allow_methods     = ["*"]
    allow_headers     = ["date", "keep-alive"]
    expose_headers    = ["keep-alive", "date"]
    max_age           = 86400
  }
}

output "api_url" {
  value = aws_lambda_function_url.api.function_url
}