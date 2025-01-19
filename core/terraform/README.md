
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.9.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 5.80.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.80.0 |
| <a name="provider_aws.use1"></a> [aws.use1](#provider\_aws.use1) | 5.80.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_k6_artifacts_bucket"></a> [k6\_artifacts\_bucket](#module\_k6\_artifacts\_bucket) | terraform-aws-modules/s3-bucket/aws | ~> 4.0 |
| <a name="module_reports_web"></a> [reports\_web](#module\_reports\_web) | ./modules/k6_reports_web | n/a |
| <a name="module_task_definition"></a> [task\_definition](#module\_task\_definition) | ./modules/ecs_task_definition | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_ecr_repository.load-testing](https://registry.terraform.io/providers/hashicorp/aws/5.80.0/docs/resources/ecr_repository) | resource |
| [aws_sns_topic.reports](https://registry.terraform.io/providers/hashicorp/aws/5.80.0/docs/resources/sns_topic) | resource |
| [aws_sns_topic_subscription.reports](https://registry.terraform.io/providers/hashicorp/aws/5.80.0/docs/resources/sns_topic_subscription) | resource |
| [aws_ssm_parameter.basic_auth_pass](https://registry.terraform.io/providers/hashicorp/aws/5.80.0/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.basic_auth_user](https://registry.terraform.io/providers/hashicorp/aws/5.80.0/docs/resources/ssm_parameter) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_artifacts_bucket_name"></a> [artifacts\_bucket\_name](#input\_artifacts\_bucket\_name) | Name of the bucket where k6 artifacts will be stored | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region | `string` | `"eu-north-1"` | no |
| <a name="input_create_artifact_bucket"></a> [create\_artifact\_bucket](#input\_create\_artifact\_bucket) | Create S3 bucket for storing artifacts | `bool` | `true` | no |
| <a name="input_create_sns_topic"></a> [create\_sns\_topic](#input\_create\_sns\_topic) | Create SNS topic for notifications | `bool` | `true` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | Domain name for the K6 reports | `string` | n/a | yes |
| <a name="input_k6_image"></a> [k6\_image](#input\_k6\_image) | K6 image | `string` | `"aws-load-test"` | no |
| <a name="input_reports_bucket_name"></a> [reports\_bucket\_name](#input\_reports\_bucket\_name) | Name of the bucket where k6 reports will be stored | `string` | n/a | yes |
| <a name="input_route53_zone_name"></a> [route53\_zone\_name](#input\_route53\_zone\_name) | Name of the Route 53 zone where the certificate will be created | `string` | n/a | yes |
| <a name="input_sns_email"></a> [sns\_email](#input\_sns\_email) | Email address for SNS notifications | `string` | `null` | no |
| <a name="input_subject_alternative_names"></a> [subject\_alternative\_names](#input\_subject\_alternative\_names) | List of subject alternative names for the certificate | `list(string)` | `[]` | no |
| <a name="input_task_cpu"></a> [task\_cpu](#input\_task\_cpu) | CPU for the Fargate task | `number` | `1024` | no |
| <a name="input_task_memory"></a> [task\_memory](#input\_task\_memory) | Memory for the Fargate task | `number` | `2048` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_artifacts_bucket_name"></a> [artifacts\_bucket\_name](#output\_artifacts\_bucket\_name) | n/a |
| <a name="output_cloudfront_id"></a> [cloudfront\_id](#output\_cloudfront\_id) | n/a |
| <a name="output_k6_reports_bucket_name"></a> [k6\_reports\_bucket\_name](#output\_k6\_reports\_bucket\_name) | n/a |
| <a name="output_reports_url"></a> [reports\_url](#output\_reports\_url) | n/a |
| <a name="output_sns_topic"></a> [sns\_topic](#output\_sns\_topic) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
