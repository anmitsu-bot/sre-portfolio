# GitHub Actions OIDC Provider
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]
}


# GitHub Actions用IAM Role
resource "aws_iam_role" "github_actions" {
  name = "sre-portfolio-github-actions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }

        Action = "sts:AssumeRoleWithWebIdentity"

        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }

          StringLike = {
            "token.actions.githubusercontent.com:sub" = [
              "repo:anmitsu-bot/sre-portfolio:ref:refs/heads/main",
              "repo:anmitsu-bot@*/sre-portfolio@*:ref:refs/heads/main"
            ]
          }
        }
      }
    ]
  })

  tags = {
    Name = "sre-portfolio-github-actions-role"
  }
}
resource "aws_iam_role_policy" "github_actions" {
  name = "sre-portfolio-github-actions-policy"
  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "ECRAuthorization"
        Effect = "Allow"

        Action = [
          "ecr:GetAuthorizationToken"
        ]

        Resource = "*"
      },

      {
        Sid    = "ECRPush"
        Effect = "Allow"

        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
        ]

        Resource = data.aws_ecr_repository.sre.arn
      },

      {
        Sid    = "ECSDeploy"
        Effect = "Allow"

        Action = [
          "ecs:DescribeTaskDefinition",
          "ecs:RegisterTaskDefinition",
          "ecs:DescribeServices"
        ]

        Resource = "*"
      },

      {
        Sid    = "ECSUpdateService"
        Effect = "Allow"

        Action = [
          "ecs:UpdateService"
        ]

        Resource = aws_ecs_service.sre_api.arn
      },

      {
        Sid    = "PassExecutionRole"
        Effect = "Allow"

        Action = [
          "iam:PassRole"
        ]

        Resource = aws_iam_role.ecs_task_execution.arn

        Condition = {
          StringEquals = {
            "iam:PassedToService" = "ecs-tasks.amazonaws.com"
          }
        }
      }
    ]
  })
}
