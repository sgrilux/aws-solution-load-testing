data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "ecs_task_execution_role" {
  statement {
    sid    = "ECRAuthorizationPolicy"
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken"
    ]
    resources = ["*"]
  }
  statement {
    sid    = "CWPolicy"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/ecs/${var.task_name}:log-stream:*"]
  }

  statement {
    sid    = "ArtifactsBucketAccessPolicy"
    effect = "Allow"
    actions = [
      "s3:GetObject",
    ]
    resources = [
      "arn:aws:s3:::${var.artifacts_bucket_name}/*"
    ]
  }

  statement {
    sid    = "ECRPolicy"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage"
    ]
    resources = ["arn:aws:ecr:${var.aws_region}:${data.aws_caller_identity.current.account_id}:repository/${var.image_name}"]
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.task_name}-task-execution-role"

  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Effect : "Allow"
        Principal : {
          Service : "ecs-tasks.amazonaws.com"
        }
        Action : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "ecs_task_execution_role" {
  name   = "${var.task_name}-task-execution-role-policy"
  role   = aws_iam_role.ecs_task_execution_role.id
  policy = data.aws_iam_policy_document.ecs_task_execution_role.json
}

data "aws_iam_policy_document" "ecs_task_role" {
  statement {
    sid    = "ArtifactsBucketAccessPolicy"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketAcl",
      "s3:List*"
    ]
    resources = [
      "arn:aws:s3:::${var.artifacts_bucket_name}",
      "arn:aws:s3:::${var.artifacts_bucket_name}/*"
    ]
  }

  statement {
    sid    = "ReportsBucketPutPolicy"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl"
    ]
    resources = [
      "arn:aws:s3:::${var.reports_bucket_name}",
      "arn:aws:s3:::${var.reports_bucket_name}/*",
    ]
  }

  dynamic "statement" {
    for_each = var.sns_topic_arn == null ? [] : [var.sns_topic_arn]
    content {
      sid    = "SNSTopicPublishPolicy"
      effect = "Allow"
      actions = [
        "sns:Publish"
      ]
      resources = [
        statement.value
      ]
    }
  }
}

resource "aws_iam_role" "ecs_task_role" {
  name = "${var.task_name}-task-role"

  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Effect : "Allow"
        Principal : {
          Service : "ecs-tasks.amazonaws.com"
        }
        Action : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "ecs_task_role" {
  name   = "${var.task_name}-task-role-policy"
  role   = aws_iam_role.ecs_task_role.id
  policy = data.aws_iam_policy_document.ecs_task_role.json
}

resource "aws_ecs_task_definition" "this" {
  family                   = var.task_name
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 2048

  container_definitions = jsonencode([
    {
      name  = var.task_name
      image = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.image_name}"

      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ],

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/${var.task_name}"
          awslogs-region        = var.aws_region
          awslogs-create-group  = "true"
          awslogs-stream-prefix = var.task_name
        }
      }

      essential = true
    }
  ])
}
