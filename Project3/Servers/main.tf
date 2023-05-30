data "aws_availability_zones" "AZs" {
  state = "available"
}

data "aws_ami" "Amazon_linux_2_AMI" {
  most_recent = true

  filter {
    name   = "name"
    values = [var.instance_ami]
  }

  owners = ["amazon"] # Canonical
}

data "aws_vpc" "Mylab_VPC_Ref" {
  id = var.aws_vpc_id
}

data "aws_iam_instance_profile" "My_iam_Profile" {
  name = "SSMroleforEC2"
}


# resource "aws_instance" "webserver" {
#   count                       = var.count_number
#   ami                         = data.aws_ami.Amazon_linux_2_AMI.id
#   availability_zone           = data.aws_availability_zones.AZs.names[count.index]
#   instance_type               = var.instance_type[0]
#   key_name                    = var.key_pair
#   associate_public_ip_address = true
#   subnet_id                   = var.subnet_ids[count.index]

#   vpc_security_group_ids = var.security_group_ids
#   tags = {
#     "Department" = local.Company_Tags.Department
#     "Company"    = local.Company_Tags.Company
#     "Name"       = "webserver-${count.index + 1}"
#   }
# }

locals {
  Company_Tags = {
    Company    = "Mylab. Inc"
    Department = var.Department
  }
}

data "aws_acm_certificate" "ACM_Certificate" {
  domain      = var.ACM_Domain
  statuses    = ["ISSUED"]
  most_recent = true
}

resource "aws_lb" "Mylab_ALB" {
  count              = var.count_number > 2 ? 1 : 0
  name               = "Mylab-ALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group_ids[2]]
  subnets            = var.subnet_ids

  tags = {
    name        = "Mylab-ALB"
    Environment = "Cybersecurity"
  }
}

resource "aws_lb_target_group" "ALB_TG" {

#  depends_on = [aws_autoscaling_group.Mylab_ASG]
  name       = "ALB-TG"
  port       = 80
  protocol   = "HTTP"
  vpc_id     = var.aws_vpc_id

  health_check {
    path                = "/"
    port                = 80
    protocol            = "HTTP"
    unhealthy_threshold = 2
    timeout             = 5
  }
}


resource "aws_lb_listener" "front_end_forward" {
  load_balancer_arn = aws_lb.Mylab_ALB[0].arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.ACM_Certificate.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ALB_TG.arn
  }
}

resource "aws_lb_listener" "front_end_redirect" {
  load_balancer_arn = aws_lb.Mylab_ALB[0].arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}


resource "aws_launch_configuration" "Mylab_Launch_Config" {
  count = var.count_number > 1 ? 1 : 0
  name_prefix     = "Mylab-LC"
  image_id        = data.aws_ami.Amazon_linux_2_AMI.id
  instance_type   = var.instance_type[0]
  user_data       = filebase64("${path.module}/myuserdata.sh")
  security_groups = var.LT_security_group
  key_name = var.key_pair
  iam_instance_profile = data.aws_iam_instance_profile.My_iam_Profile.name

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "Mylab_ASG" {
  count = var.count_number > 1 ? 1 : 0
  #  depends_on = [aws_launch_template.Mylab_Launch_Template]
  #availability_zones = toset([for i in range(var.count_number) : data.aws_availability_zones.AZs.names[i]])
  vpc_zone_identifier       = var.subnet_ids
  desired_capacity          = 3 #var.count_number
  max_size                  = 5 #var.count_number + 2
  min_size                  = 2 #var.count_number - 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  force_delete              = true
  #wait_for_capacity_timeout = "3m"
  launch_configuration = aws_launch_configuration.Mylab_Launch_Config[0].name
  #target_group_arns = [ aws_lb_target_group.ALB_TG.arn ]
  name = "Mylab-ASG"
  tag {
    propagate_at_launch = true
    key = "Name"
    value = "webserver-${count.index + 1}"
  }
}


resource "aws_autoscaling_attachment" "asg_attachment_newb" {
  autoscaling_group_name = aws_autoscaling_group.Mylab_ASG[0].id
  lb_target_group_arn    = aws_lb_target_group.ALB_TG.arn

}

data "aws_route53_zone" "my_hosted_zone" {
  name = var.hosted_zone
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.my_hosted_zone.zone_id
  name    = "terraform.myaws2022lab.com"
  type    = "A"
  alias {
    name                   = aws_lb.Mylab_ALB[0].dns_name
    zone_id                = aws_lb.Mylab_ALB[0].zone_id
    evaluate_target_health = true
  }
}