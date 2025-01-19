output "k6_reports_bucket_name" {
  value = var.reports_bucket_name
}

output "artifacts_bucket_name" {
  value = var.artifacts_bucket_name
}

output "reports_url" {
  value = "https://${var.domain_name}"
}

output "cloudfront_id" {
  value = module.reports_web.cloudfront_id
}

output "sns_topic" {
  value = var.create_sns_topic ? aws_sns_topic.reports[0].arn : ""
}
