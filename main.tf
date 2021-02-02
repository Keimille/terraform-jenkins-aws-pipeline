resource "aws_vpc" "main_vpc" {
  cidr_block = var.cidr

  enable_dns_hostnames = true
  tags = {
    Name = var.vpc_tag_value
  }
}


resource "aws_subnet" "public" {
  depends_on = [
    aws_vpc.main_vpc
  ]

  # VPC in which subnet has to be created!
  vpc_id = aws_vpc.main_vpc.id

  # IP Range of this subnet
  cidr_block = var.public-subnet

  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet"
  }
}

# Creating Private subnet
resource "aws_subnet" "private" {
  depends_on = [
    aws_vpc.main_vpc,
    aws_subnet.public
  ]

  # VPC in which subnet has to be created
  vpc_id = aws_vpc.main_vpc.id

  # IP Range of this subnet
  cidr_block = var.private-subnet

  tags = {
    Name = "Private Subnet"
  }
}

# Creating an Internet Gateway for the VPC
resource "aws_internet_gateway" "Internet_Gateway" {
  depends_on = [
    aws_vpc.main_vpc,
    aws_subnet.public,
    aws_subnet.private
  ]

  # VPC in which it has to be created
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "IG-Public-&-Private-VPC"
  }
}

# Create a Route Table for the public subnet
resource "aws_route_table" "Public-Subnet-RT" {
  depends_on = [
    aws_vpc.main_vpc,
    aws_internet_gateway.Internet_Gateway
  ]

  # VPC ID
  vpc_id = aws_vpc.main_vpc.id

  # NAT Rule
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Internet_Gateway.id
  }

  tags = {
    Name = "Route Table for Internet Gateway"
  }
}

resource "aws_route_table_association" "RT-IG-Association" {

  depends_on = [
    aws_vpc.main_vpc,
    aws_subnet.public,
    aws_subnet.private,
    aws_route_table.Public-Subnet-RT
  ]

  # Public Subnet ID
  subnet_id = aws_subnet.public.id

  #  Route Table ID
  route_table_id = aws_route_table.Public-Subnet-RT.id
}

# Creating a Security Group for the web server
resource "aws_security_group" "Jenkins-Master-sg" {

  depends_on = [
    aws_vpc.main_vpc,
    aws_subnet.public,
    aws_subnet.private
  ]

  description = "HTTP, PING, SSH"

  # Name of the security Group
  name = "Jenkins-Master-sg"

  # VPC ID in which Security group has to be created
  vpc_id = aws_vpc.main_vpc.id

  # Created an inbound rule for webserver access
  ingress {
    description = "HTTP for Jenkins Master"
    from_port   = 80
    to_port     = 8080


    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "port 8080 for Jenkins Master"
    from_port   = 8080
    to_port     = 8080


    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS for Jenkins Master"
    from_port   = 443
    to_port     = 8080


    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Created an inbound rule for ping
  ingress {
    description = "Ping"
    from_port   = 0
    to_port     = 0
    protocol    = "ICMP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outward Network Traffic for the webserver
  egress {
    description = "output from Jenkins"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "Jenkins-Node-sg" {

  depends_on = [
    aws_vpc.main_vpc,
    aws_subnet.public,
    aws_subnet.private
  ]

  description = "HTTP, PING, SSH"

  # Name of the security Group
  name = "Jenkins-Node-sg"

  # VPC ID in which Security group has to be created
  vpc_id = aws_vpc.main_vpc.id

  # Created an inbound rule for webserver access
  ingress {
    description = "HTTP for Jenkins Node"
    from_port   = 80
    to_port     = 80


    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "port 8080 for Jenkins Node"
    from_port   = 443
    to_port     = 443


    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Created an inbound rule for ping
  ingress {
    description = "Ping"
    from_port   = 0
    to_port     = 0
    protocol    = "ICMP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outward Network Traffic for the webserver
  egress {
    description = "output from Node"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "Jenkins-Master" {
  ami                         = "ami-0885b1f6bd170450c"
  vpc_security_group_ids      = ["${aws_security_group.Jenkins-Master-sg.id}"]
  instance_type               = var.instance-type
  subnet_id                   = aws_subnet.public.id
  count                       = var.ec2count
  associate_public_ip_address = true

  user_data        = "${file("Jenkinsmaster.sh")}"
  user_data_base64 = var.user_data_base_64
  key_name         = var.key_name
}

resource "aws_instance" "Jenkins-Node" {
  ami                         = var.ami
  vpc_security_group_ids      = ["${aws_security_group.Jenkins-Master-sg.id}"]
  instance_type               = var.instance-type
  subnet_id                   = aws_subnet.public.id
  count                       = var.ec2count
  associate_public_ip_address = true

  user_data        = var.user_data
  user_data_base64 = var.user_data_base_64
  key_name         = var.key_name
}

