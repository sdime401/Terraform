# output "instance_public_ip" {
#   #value = aws_instance.webserver.public_ip
#   value = [for inst in aws_instance.webserver : inst.public_ip]
# }
# output "instance_private_ip" {
#   #value = aws_instance.webserver[count.index].private_ip
#   value = [for inst in aws_instance.webserver : inst.private_ip]
# }

output "lb_endpoint" {
  value = "https://${aws_lb.Mylab_ALB[0].dns_name}"
}

output "application_endpoint" {
  value = "https://${aws_lb.Mylab_ALB[0].dns_name}/index.html"
}

output "asg_name" {
  value = aws_autoscaling_group.Mylab_ASG[0].name
}

output "alias_record_name" {
  value = aws_route53_record.www.fqdn
}

