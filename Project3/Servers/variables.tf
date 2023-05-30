
variable "instance_ami" {
  type = string

}

variable "instance_type" {
  type    = list(string)
  default = ["t3.micro"]
}

variable "key_pair" {
  type = string
}

variable "domain" {
  type    = string
  default = "*.myaws2022lab.com"

}

variable "ACM_Domain" {
  type = string

}

variable "Department" {
  type = string

}

variable "count_number" {
  type    = number
  default = 3

}

variable "aws_vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)

}

variable "security_group_ids" {
  type        = list(string)
  description = "List of public subnets"

}

variable "LT_security_group" {
  type = list(string)

}

variable "hosted_zone" {
  type = string
  
}