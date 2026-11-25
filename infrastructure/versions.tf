terraform {
  required_version = ">= 1.12.0, < 2.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.42"
    }
  }
}
provider "aws" {
  region              = "us-east-1"
  allowed_account_ids = [var.expected_account_id]
}
