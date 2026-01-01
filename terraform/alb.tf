resource "aws_lb" "fastapi-ecs" {
  name               = "${var.app_name}-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [aws_security_group.fastapi_ecs_alb_sg.id]
  subnets         = data.aws_subnets.default.ids

  enable_deletion_protection = false

  depends_on = [
    aws_s3_bucket.alb_logs
  ]

  access_logs {
    bucket  = aws_s3_bucket.alb_logs.id
    prefix  = "${var.app_name}/alb"
    enabled = true
  }

  tags = {
    Name = "${var.app_name}-alb"
  }
}

resource "aws_lb_listener" "fastapi-ecs" {
  load_balancer_arn = aws_lb.fastapi-ecs.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.fastapi-ecs.arn
  }

  depends_on = [aws_lb.fastapi-ecs]
}

resource "aws_lb_target_group" "fastapi-ecs" {
  name        = "${var.app_name}-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = data.aws_vpc.default.id
}
