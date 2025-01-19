# K6 Reports

This module deploys the infrastructure for K6 reports.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 5.80.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.80.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_acm"></a> [acm](#module\_acm) | terraform-aws-modules/acm/aws | ~> 4.0 |
| <a name="module_basic_auth_lambda_function"></a> [basic\_auth\_lambda\_function](#module\_basic\_auth\_lambda\_function) | terraform-aws-modules/lambda/aws | ~>7.0 |
| <a name="module_cloudfront"></a> [cloudfront](#module\_cloudfront) | terraform-aws-modules/cloudfront/aws | 3.4.1 |
| <a name="module_dns_record"></a> [dns\_record](#module\_dns\_record) | terraform-aws-modules/route53/aws//modules/records | ~> 2.0 |
| <a name="module_k6_reports"></a> [k6\_reports](#module\_k6\_reports) | terraform-aws-modules/s3-bucket/aws | ~> 4.0 |
| <a name="module_k6_reports_bucket_notification"></a> [k6\_reports\_bucket\_notification](#module\_k6\_reports\_bucket\_notification) | terraform-aws-modules/s3-bucket/aws//modules/notification | ~> 4.0 |
| <a name="module_log_bucket"></a> [log\_bucket](#module\_log\_bucket) | terraform-aws-modules/s3-bucket/aws | ~> 4.0 |
| <a name="module_update_reports_list_lambda"></a> [update\_reports\_list\_lambda](#module\_update\_reports\_list\_lambda) | terraform-aws-modules/lambda/aws | ~>7.0 |

## Resources

| Name | Type |
|------|------|
| [aws_s3_bucket_policy.reports](https://registry.terraform.io/providers/hashicorp/aws/5.80.0/docs/resources/s3_bucket_policy) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/5.80.0/docs/data-sources/caller_identity) | data source |
| [aws_canonical_user_id.current](https://registry.terraform.io/providers/hashicorp/aws/5.80.0/docs/data-sources/canonical_user_id) | data source |
| [aws_cloudfront_log_delivery_canonical_user_id.cloudfront](https://registry.terraform.io/providers/hashicorp/aws/5.80.0/docs/data-sources/cloudfront_log_delivery_canonical_user_id) | data source |
| [aws_iam_policy_document.k6_reports](https://registry.terraform.io/providers/hashicorp/aws/5.80.0/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.lambda_basic_auth](https://registry.terraform.io/providers/hashicorp/aws/5.80.0/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.update_reports_list_lambda](https://registry.terraform.io/providers/hashicorp/aws/5.80.0/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/5.80.0/docs/data-sources/region) | data source |
| [aws_route53_zone.this](https://registry.terraform.io/providers/hashicorp/aws/5.80.0/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_basic_auth_password_ssm"></a> [basic\_auth\_password\_ssm](#input\_basic\_auth\_password\_ssm) | SSM parameter name for basic auth password | `string` | n/a | yes |
| <a name="input_basic_auth_user_ssm"></a> [basic\_auth\_user\_ssm](#input\_basic\_auth\_user\_ssm) | SSM parameter name for basic auth user | `string` | n/a | yes |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | Name of the bucket where k6 output will be stored | `string` | n/a | yes |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | Domain name for the report UI | `string` | n/a | yes |
| <a name="input_route53_zone_name"></a> [route53\_zone\_name](#input\_route53\_zone\_name) | Name of the Route 53 zone where the certificate will be created | `string` | n/a | yes |
| <a name="input_subject_alternative_names"></a> [subject\_alternative\_names](#input\_subject\_alternative\_names) | List of subject alternative names for the certificate | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudfront_id"></a> [cloudfront\_id](#output\_cloudfront\_id) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
