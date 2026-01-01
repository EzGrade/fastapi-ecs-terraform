output "ecr_repository_url" {
  value = aws_ecr_repository.fastapi-ecs.repository_url
}

output "alb_dns" {
  value = aws_lb.fastapi-ecs.dns_name
}
