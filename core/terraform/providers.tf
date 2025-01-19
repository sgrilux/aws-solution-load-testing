provider "aws" {
  alias  = "default"
  region = var.aws_region
}

provider "aws" {
  alias  = "use1"
  region = "us-east-1"
}
