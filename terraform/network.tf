# 既存のdefault VPCを取得
data "aws_vpc" "default" {
  default = true
}

# ECS用Security Group
resource "aws_security_group" "sre_api" {
  name        = "sre-portfolio-tf-sg"
  description = "Security group for SRE Portfolio API"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Name = "sre-portfolio-tf-sg"
  }
}

# FastAPIの8000番ポートを許可
resource "aws_vpc_security_group_ingress_rule" "fastapi" {
  security_group_id = aws_security_group.sre_api.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 8000
  to_port     = 8000
  ip_protocol = "tcp"

  description = "Allow FastAPI access"
}

# ECSから外部への通信を許可
resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.sre_api.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}