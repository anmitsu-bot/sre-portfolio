resource "aws_cloudwatch_log_group" "sre_api" {
  name              = "/ecs/sre-portfolio-tf"
  retention_in_days = 7

  tags = {
    Name = "sre-portfolio-tf"
  }
}