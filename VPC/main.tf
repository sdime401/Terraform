terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-west-2"
}

resource "aws_vpc" "my_vpc" {

  cidr_block = "10.0.0.0/16"
  tags = {
    "Name" = "my_vpc"
  }

}