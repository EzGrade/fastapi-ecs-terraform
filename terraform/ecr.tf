resource "aws_ecr_repository" "fastapi-ecs" {
  name                 = "fastapi-ecs-repo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}
