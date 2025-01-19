variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "task_name" {
  description = "Name of the task definition"
  type        = string
}

variable "image_name" {
  description = "Name of the docker image"
  type        = string
}

variable "memory" {
  description = "The amount (in MiB) of memory to present to the container"
  type        = number
  default     = 512
}

variable "cpu" {
  description = "The number of cpu units reserved for the container"
  type        = number
  default     = 256
}

variable "artifacts_bucket_name" {
  description = "Name of the S3 bucket where the artifacts are stored"
  type        = string
}

variable "reports_bucket_name" {
  description = "Name of the S3 bucket where the k6 results will be uploaded"
  type        = string
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic to send notifications to"
  type        = string
}
