terraform {
  required_version = "~> 1.1.4"
  required_providers {
    aws = {
      version = ">= 3.74.0"
      source = "hashicorp/aws"
    }
  }
}