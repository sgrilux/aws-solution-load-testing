data "aws_canonical_user_id" "current" {}
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_cloudfront_log_delivery_canonical_user_id" "cloudfront" {}

data "aws_route53_zone" "this" {
  name = var.route53_zone_name
}
