# ________________________________PROVIDER________________________________
terraform {
    backend "s3" {
    bucket         = "terraform-state-warehouse"
    key            = "terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terraform-tfstate-lock"
    encrypt        = true
  }
}
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }  
  required_version = ">= 1.0.8"
}

# Configure the AWS Provider
provider "aws" {
  access_key = "${var.AWS_ID}"
  secret_key = "${var.AWS_SECRET_KEY}"
  region     = "${var.availability_zone[0]}"
}
