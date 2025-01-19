terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "5.80.0"
      configuration_aliases = [aws, aws.use1]
    }

    random = {
      source  = "hashicorp/random"
      version = ">= 2.0"
    }
  }
}
