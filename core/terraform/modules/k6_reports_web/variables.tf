variable "bucket_name" {
  description = "Name of the bucket where k6 output will be stored"
  type        = string
}

variable "route53_zone_name" {
  description = "Name of the Route 53 zone where the certificate will be created"
  type        = string
}

variable "domain_name" {
  description = "Domain name for the report UI"
  type        = string
}

variable "subject_alternative_names" {
  description = "List of subject alternative names for the certificate"
  type        = list(string)
  default     = []
}

variable "basic_auth_user_ssm" {
  description = "SSM parameter name for basic auth user"
  type        = string
}

variable "basic_auth_password_ssm" {
  description = "SSM parameter name for basic auth password"
  type        = string
}
