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

resource "aws_instance" "my_ec2" {

  ami           = "ami-009c5f630e96948cb"
  instance_type = "t3.micro"
  key_name      = "awesome_key"

  tags = {
    "Name" = "my-ec2"
  }


}