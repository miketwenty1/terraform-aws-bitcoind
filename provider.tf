terraform {
  required_providers {
    aws = {
      version = ">= 2.7.0"
      source = "hashicorp/aws"
    }
    template = {
      source = "hashicorp/template"
    }
  }
  required_version = ">= 0.15"
}