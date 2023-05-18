resource "aws_vpc" "my_vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  tags = {
    Name = "project_1_VPC"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "project-1-igw"
  }
}

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

resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.public_subnet_cidrs[0]
  availability_zone       = data.aws_availability_zones.AZs.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.public_subnet_cidrs[1]
  availability_zone = data.aws_availability_zones.AZs.names[1]
  #  map_customer_owned_ip_on_launch = true

  tags = {
    Name = "public-subnet-2"
  }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.private_subnet_cidrs[0]
  availability_zone = data.aws_availability_zones.AZs.names[0]

  tags = {
    Name = "private-subnet-1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.private_subnet_cidrs[1]
  availability_zone = data.aws_availability_zones.AZs.names[1]

  tags = {
    Name = "private-subnet-2"
  }
}

resource "aws_route_table" "Public_RT" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = var.public_destination_RT
    gateway_id = aws_internet_gateway.igw.id
  }
#  route = {
#    cidr_block = aws_subnet.public_subnet_2.cidr_block
#    gateway_id = aws_internet_gateway.igw.id
#  }

  tags = {
    "Name" = "Public-RT"
  }

}

resource "aws_route_table_association" "association_PS2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.Public_RT.id
}

resource "aws_route_table_association" "association_PS1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.Public_RT.id
}

resource "aws_security_group" "Public_SG" {
  name        = "Public_SG"
  description = "Allow inbound traffic to the public nodes"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    description = "https from the public "
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.anywhere_cidr]

  }
  ingress {
    description = "http from the public "
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.anywhere_cidr]

  }

  ingress {
    description = "SSH from private location "
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.Proprietary_address]

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.anywhere_cidr]
  }

  tags = {
    Name = "Public-SG"
  }
}


resource "aws_instance" "webserver" {

  ami                         = data.aws_ami.Amazon_linux_2_AMI.id
  availability_zone           = data.aws_availability_zones.AZs.names[0]
  instance_type               = var.instance_type[0]
  key_name                    = var.key_pair
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public_subnet_1.id
  vpc_security_group_ids      = [aws_security_group.Public_SG.id]
  tags = {
    "Department" = local.Company_Tags.Department
    "Company"    = local.Company_Tags.Company
    "Name"       = local.Company_Tags.Name
  }


}

locals {
  Company_Tags = {
    Company    = "Dojo. Inc"
    Department = var.Department
    Name       = "Dojo-webserser"
  }
}