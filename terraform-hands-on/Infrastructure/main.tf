resource "aws_vpc" "my_vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  tags = {
    Name = "MyLab-VPC"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "MyLab-igw"
  }
}

data "aws_availability_zones" "AZs" {
  state = "available"
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
  map_public_ip_on_launch = true
  #  map_customer_owned_ip_on_launch = true

  tags = {
    Name = "public-subnet-2"
  }
}

resource "aws_subnet" "public_subnet_3" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.public_subnet_cidrs[2]
  availability_zone = data.aws_availability_zones.AZs.names[2]
  map_public_ip_on_launch = true
  #  map_customer_owned_ip_on_launch = true

  tags = {
    Name = "public-subnet-3"
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

resource "aws_subnet" "private_subnet_3" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.private_subnet_cidrs[2]
  availability_zone = data.aws_availability_zones.AZs.names[2]

  tags = {
    Name = "private-subnet-3"
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

resource "aws_route_table_association" "association_PS3" {
  subnet_id      = aws_subnet.public_subnet_3.id
  route_table_id = aws_route_table.Public_RT.id
}

resource "aws_security_group" "ALB_SG" {
  name        = "ALB_SG"
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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.anywhere_cidr]
  }

  tags = {
    Name = "ALB-SG"
  }
}

resource "aws_security_group" "SSH_SG" {

  name        = "SSH-SG"
  description = "Allow SSH traffic from Proprietary address"
  vpc_id      = aws_vpc.my_vpc.id

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
    Name = "SSH-SG"
  }
}

resource "aws_security_group" "Webserver_SG" {
  name        = "Webserver-SG"
  description = "Webserver traffic to the ALB"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    description     = "HTTP from ALB "
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.ALB_SG.id]


  }
  ingress {
    description = "HTTPS from the ALB"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.ALB_SG.id]

  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.anywhere_cidr]
  }
  tags = {
    Name = "Webserver-SG"
  }
}