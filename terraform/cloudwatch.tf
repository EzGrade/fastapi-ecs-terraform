resource "aws_cloudwatch_log_group" "fastapi-app" {
  name              = "/ecs/${var.app_name}-log-group"
  retention_in_days = 14
}
