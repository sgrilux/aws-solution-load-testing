module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  validation_method         = "DNS"
  domain_name               = var.domain_name
  zone_id                   = data.aws_route53_zone.this.id
  subject_alternative_names = var.subject_alternative_names

  providers = {
    aws = aws.use1
  }
}

# Logging bucket for CloudFront
module "log_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 4.0"

  bucket = "logs-${var.domain_name}"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  grant = [{
    type       = "CanonicalUser"
    permission = "FULL_CONTROL"
    id         = data.aws_canonical_user_id.current.id
    }, {
    type       = "CanonicalUser"
    permission = "FULL_CONTROL"
    id         = data.aws_cloudfront_log_delivery_canonical_user_id.cloudfront.id

  }]

  force_destroy = true
}

# K6 reports bucket
module "k6_reports" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 4.0"

  bucket        = var.bucket_name
  force_destroy = true
}

data "aws_iam_policy_document" "k6_reports" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${module.k6_reports.s3_bucket_arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [module.cloudfront.cloudfront_distribution_arn]
    }
  }
}
resource "aws_s3_bucket_policy" "reports" {
  bucket = module.k6_reports.s3_bucket_id
  policy = data.aws_iam_policy_document.k6_reports.json
}

#
# Update reports list lambda
#
data "aws_iam_policy_document" "update_reports_list_lambda" {
  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject"
    ]
    resources = [
      module.k6_reports.s3_bucket_arn,
      "${module.k6_reports.s3_bucket_arn}/*"
    ]
  }
}

module "update_reports_list_lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~>7.0"

  function_name = "UpdateReportsList"
  description   = "Lambda that creates a list of files presents in the reports folder"
  handler       = "index.handler"
  runtime       = "python3.12"
  source_path   = "../lambdas/updateFileList/index.py"

  publish = true

  attach_policy_json = true
  policy_json        = data.aws_iam_policy_document.update_reports_list_lambda.json

  environment_variables = {
    REPORTS_BUCKET_NAME = module.k6_reports.s3_bucket_id
  }
}

#
# S3 Notification to Lambda
#
module "k6_reports_bucket_notification" {
  source  = "terraform-aws-modules/s3-bucket/aws//modules/notification"
  version = "~> 4.0"

  bucket = module.k6_reports.s3_bucket_id

  lambda_notifications = {
    lambda1 = {
      function_arn  = module.update_reports_list_lambda.lambda_function_arn
      function_name = module.update_reports_list_lambda.lambda_function_name
      events        = ["s3:ObjectCreated:Put"]
      filter_prefix = "reports/"
    }
  }
}
#
# CloudFront distribution for K6 reports
#
module "cloudfront" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "3.4.1"

  aliases = [var.domain_name]
  comment = "K6 Results"

  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_100"
  retain_on_delete    = false
  wait_for_deployment = false
  default_root_object = "index.html"

  create_origin_access_control = true
  origin_access_control = {
    k6_reports = {
      description      = "CloudFront Access to K6 Reports Bucket"
      origin_type      = "s3"
      signing_behavior = "always"
      signing_protocol = "sigv4"
    }
  }

  logging_config = {
    bucket = module.log_bucket.s3_bucket_bucket_domain_name
    prefix = "cloudfront"
  }

  origin = {
    k6_reports = {
      domain_name           = module.k6_reports.s3_bucket_bucket_regional_domain_name
      origin_access_control = "k6_reports"
    }
  }

  default_cache_behavior = {
    target_origin_id       = "k6_reports"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]

    use_forwarded_values = false

    compress     = true
    query_string = true
    cookies = {
      forward = "all"
    }

    cache_policy_name            = "Managed-CachingOptimized"
    origin_request_policy_name   = "Managed-UserAgentRefererHeaders"
    response_headers_policy_name = "Managed-SimpleCORS"

    lambda_function_association = {
      viewer-request = {
        lambda_arn   = module.basic_auth_lambda_function.lambda_function_qualified_arn
        include_body = true
      }

    }
  }
  viewer_certificate = {
    minimum_protocol_version = "TLSv1.2_2021"
    acm_certificate_arn      = module.acm.acm_certificate_arn
    ssl_support_method       = "sni-only"
  }

  providers = {
    aws = aws.use1
  }
}

#
# Create Basic Auth Lambda function
#
data "aws_iam_policy_document" "lambda_basic_auth" {
  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath"
    ]
    resources = [
      var.basic_auth_user_ssm,
      var.basic_auth_password_ssm
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey"
    ]
    resources = [
      "arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:key/alias/aws/ssm"
    ]
  }
}

module "basic_auth_lambda_function" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~>7.0"

  function_name = "BasicAuthLambda"
  description   = "Cloudfront auth lambda function"
  handler       = "index.handler"
  runtime       = "python3.12"
  source_path   = "../lambdas/basicAuth/index.py"

  publish        = true
  lambda_at_edge = true

  attach_policy_json = true
  policy_json        = data.aws_iam_policy_document.lambda_basic_auth.json

  allowed_triggers = {
    AllowExecutionFromCloudFront = {
      service    = "cloudfront"
      source_arn = module.cloudfront.cloudfront_distribution_arn
    }
  }
  providers = {
    aws = aws.use1
  }
}

module "dns_record" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 2.0"

  zone_id = data.aws_route53_zone.this.zone_id

  records = [
    {
      name = "k6"
      type = "A"
      alias = {
        name    = module.cloudfront.cloudfront_distribution_domain_name
        zone_id = module.cloudfront.cloudfront_distribution_hosted_zone_id
      }
    },
  ]
}
