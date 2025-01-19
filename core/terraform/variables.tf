variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "eu-north-1"

  validation {
    condition     = can(regex("[a-z][a-z]-[a-z]+-[1-9]", var.aws_region))
    error_message = "Must be valid AWS Region name."
  }
}

variable "create_artifact_bucket" {
  description = "Create S3 bucket for storing artifacts"
  type        = bool
  default     = true
}

variable "reports_bucket_name" {
  description = "Name of the bucket where k6 reports will be stored"
  type        = string
}

variable "artifacts_bucket_name" {
  description = "Name of the bucket where k6 artifacts will be stored"
  type        = string
}

variable "route53_zone_name" {
  description = "Name of the Route 53 zone where the certificate will be created"
  type        = string
}

variable "domain_name" {
  description = "Domain name for the K6 reports"
  type        = string
}

variable "subject_alternative_names" {
  description = "List of subject alternative names for the certificate"
  type        = list(string)
  default     = []
}

variable "k6_image" {
  description = "K6 image"
  type        = string
  default     = "aws-load-test"
}

variable "task_memory" {
  description = "Memory for the Fargate task"
  type        = number
  default     = 2048
}

variable "task_cpu" {
  description = "CPU for the Fargate task"
  type        = number
  default     = 1024
}

variable "create_sns_topic" {
  description = "Create SNS topic for notifications"
  type        = bool
  default     = true
}

variable "sns_email" {
  description = "Email address for SNS notifications"
  type        = string
  default     = null

  validation {
    condition     = can(regex("[^@]+@[^@]+", var.sns_email))
    error_message = "Must be a valid email address."
  }
}
