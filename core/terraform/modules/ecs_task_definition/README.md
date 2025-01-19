# ECS Task Definition module

This module deploys and ECS Task Definition

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 5.80.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.80.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ecs_task_definition.this](https://registry.terraform.io/providers/hashicorp/aws/5.80.0/docs/resources/ecs_task_definition) | resource |
| [aws_iam_role.ecs_task_execution_role](https://registry.terraform.io/providers/hashicorp/aws/5.80.0/docs/resources/iam_role) | resource |
| [aws_iam_role.ecs_task_role](https://registry.terraform.io/providers/hashicorp/aws/5.80.0/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.ecs_task_execution_role](https://registry.terraform.io/providers/hashicorp/aws/5.80.0/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.ecs_task_role](https://registry.terraform.io/providers/hashicorp/aws/5.80.0/docs/resources/iam_role_policy) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/5.80.0/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.ecs_task_execution_role](https://registry.terraform.io/providers/hashicorp/aws/5.80.0/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ecs_task_role](https://registry.terraform.io/providers/hashicorp/aws/5.80.0/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_artifacts_bucket_name"></a> [artifacts\_bucket\_name](#input\_artifacts\_bucket\_name) | Name of the S3 bucket where the artifacts are stored | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_cpu"></a> [cpu](#input\_cpu) | The number of cpu units reserved for the container | `number` | `256` | no |
| <a name="input_image_name"></a> [image\_name](#input\_image\_name) | Name of the docker image | `string` | n/a | yes |
| <a name="input_memory"></a> [memory](#input\_memory) | The amount (in MiB) of memory to present to the container | `number` | `512` | no |
| <a name="input_reports_bucket_name"></a> [reports\_bucket\_name](#input\_reports\_bucket\_name) | Name of the S3 bucket where the k6 results will be uploaded | `string` | n/a | yes |
| <a name="input_sns_topic_arn"></a> [sns\_topic\_arn](#input\_sns\_topic\_arn) | ARN of the SNS topic to send notifications to | `string` | n/a | yes |
| <a name="input_task_name"></a> [task\_name](#input\_task\_name) | Name of the task definition | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | ARN of the ECS Task Definition |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
