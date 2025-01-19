# Artifacts bucket that contains k6 scripts
module "k6_artifacts_bucket" {
  count = var.create_artifact_bucket ? 1 : 0

  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 4.0"

  bucket        = var.artifacts_bucket_name
  force_destroy = true
}

# SSM Parameter to store basic auth user.
resource "aws_ssm_parameter" "basic_auth_user" {
  name        = "/load-testing/basic-auth-user"
  description = "Basic auth user for k6 reports"
  type        = "SecureString"
  value       = "CHANGE_ME"

  lifecycle {
    ignore_changes = [value]
  }

  provider = aws.use1
}

# SSM Parameter to store basic auth password
resource "aws_ssm_parameter" "basic_auth_pass" {
  name        = "/load-testing/basic-auth-password"
  description = "Basic auth password for k6 reports"
  type        = "SecureString"
  value       = "CHANGE_ME"

  lifecycle {
    ignore_changes = [value]
  }

  provider = aws.use1
}

# Module to deploy the k6 bucket for reports and a Cloudfront
module "reports_web" {
  source = "./modules/k6_reports_web"

  bucket_name               = var.reports_bucket_name
  basic_auth_user_ssm       = aws_ssm_parameter.basic_auth_user.arn
  basic_auth_password_ssm   = aws_ssm_parameter.basic_auth_pass.arn
  domain_name               = var.domain_name
  route53_zone_name         = var.route53_zone_name
  subject_alternative_names = var.subject_alternative_names

  providers = {
    aws      = aws.default
    aws.use1 = aws.use1
  }
}

# SNS Topic to send alerts via mail
resource "aws_sns_topic" "reports" {
  count = var.create_sns_topic ? 1 : 0

  name              = "k6_reports"
  kms_master_key_id = "alias/aws/sns"
}

resource "aws_sns_topic_subscription" "reports" {
  count = var.create_sns_topic ? 1 : 0

  topic_arn = aws_sns_topic.reports[0].arn
  protocol  = "email"
  endpoint  = var.sns_email
}

# ECR Repository
resource "aws_ecr_repository" "load-testing" {
  name                 = "aws-load-testing"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# Module to deploy the task definition
module "task_definition" {
  source = "./modules/ecs_task_definition"

  task_name             = "aws-load-testing"
  artifacts_bucket_name = var.artifacts_bucket_name
  reports_bucket_name   = var.reports_bucket_name
  sns_topic_arn         = var.create_sns_topic ? aws_sns_topic.reports[0].arn : null
  image_name            = var.k6_image
  aws_region            = var.aws_region
  memory                = var.task_memory
  cpu                   = var.task_cpu
}
