terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.98.0"
    }
  }
  backend "s3" {
    bucket = "fiap-soat-architecture-lambda-tf-state"
    key    = "terraform.tfstate"
    region = var.aws_region
  }
}

provider "aws" {
  region  = var.aws_region
}