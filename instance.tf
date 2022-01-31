#provider information
provider "aws" {
  region  = "us-east-1"
  profile = "Terraform"

}

#Create a VPC
resource "aws_vpc" "amazon" {
  cidr_block = "10.0.0.0/16"
  tags = {
    "Name" = "Amazon"
  }
}

#create a PUBLIC SUBNET

resource "aws_subnet" "amz_pub_sub" {
  vpc_id                  = aws_vpc.amazon.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "AmazonPublicSub"
  }
}
#create a PRIVATE SUBNET

resource "aws_subnet" "amz_pvt_sub" {
  vpc_id                  = aws_vpc.amazon.id
  cidr_block              = "10.0.2.0/24"
   availability_zone       = "us-east-1b"
  map_public_ip_on_launch = "false"

  tags = {
    Name = "AmazonPrivateSub"
  }
}

resource "aws_internet_gateway" "amazon_gw" {
  vpc_id = aws_vpc.amazon.id

  tags = {
    Name = "amazonIGW"
  }
}

#create a ROUTE TABLE
resource "aws_route_table" "AmazonRT" {
  vpc_id = aws_vpc.amazon.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.amazon_gw.id
  }

  tags = {
    Name = "AmazonRT"
  }
}
#RouteTable association
resource "aws_route_table_association" "amazonRT" {
  subnet_id      = aws_subnet.amz_pub_sub.id
  route_table_id = aws_route_table.AmazonRT.id
}

#create security group

resource "aws_security_group" "amazon_sg" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.amazon.id

  ingress {

    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {
    Name = "allow_app"
  }
}
#create EC2 instance
resource "aws_instance" "Amazon_ec2" {

  ami                    = "ami-0a8b4cd432b1c3063"
  instance_type          = "t2.micro"
  key_name               = "keypair"
  monitoring             = true
  count                  = 2
  vpc_security_group_ids = [aws_security_group.amazon_sg.id]
  subnet_id              = aws_subnet.amz_pub_sub.id

  tags = {
    NAME = "ECOMM"
  }
}
