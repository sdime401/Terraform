output "aws_vpc" {
  value = aws_vpc.my_vpc.id

}

output "ALB_SG" {
  value = aws_security_group.ALB_SG

}
