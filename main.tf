# main.tf

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  # This uses the credentials you set up with 'aws configure'
  region = "us-east-1" 
}

# The archive data source for packaging the Python code
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "src"
  output_path = "auditor_package.zip"
}