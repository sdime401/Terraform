variable "aws_region" {
  description = "The AWS region to be used"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  type        = string
  description = "This is the VPC cidr block to be used"
}


variable "public_subnet_cidrs" {
  description = "A list of CIDR blocks for the public subnets"
  type        = list(string)
}


variable "private_subnet_cidrs" {
  description = "A list of CIDR blocks for the private subnets"
  type        = list(string)
}

variable "anywhere_cidr" {
  type    = string
  default = "0.0.0.0/0"

}

variable "Proprietary_address" {
  type = string

}


variable "domain" {
  type    = string
  default = "myaws2022lab.com"

}

variable "public_destination_RT" {
  type    = string
  default = "0.0.0.0/0"

}

#variable "public_subnet_ids" {
#  type        = list(any)
#  description = "The list of public subnet ids"
#  default     = []

#}

variable "private_subnet_ids" {
  type        = list(string)
  description = "The list of public subnet ids"
  default     = []

}