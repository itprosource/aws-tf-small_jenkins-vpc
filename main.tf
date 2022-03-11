# Data Sources
data "aws_ami" "ubuntu" {
  most_recent = true
  owners = ["099720109477"]

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-*-amd64-server-*"]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }

}

# VPC
resource "aws_vpc" "vpc" {
  cidr_block = var.cidr

  tags = {
    Name = var.name
  }
}

# Subnet
resource "aws_subnet" "public" {
  cidr_block = var.public_subnet
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.name}-pub"
  }
}

# IGW
resource "aws_internet_gateway" "int_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = var.name
  }
}

# Route Table
resource "aws_route_table" "public_rte" {
  vpc_id = aws_vpc.vpc.id
  depends_on = [aws_internet_gateway.int_gateway]

  tags = {
    Name = "${var.name}-public"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.int_gateway.id
  }
}

resource "aws_route_table_association" "association_public_rte" {
  subnet_id = aws_subnet.public.id
  route_table_id = aws_route_table.public_rte.id
}

# EC2
resource "aws_instance" "instance" {
  ami = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  associate_public_ip_address = var.associate_public_ip_address
  subnet_id = aws_subnet.public.id
  key_name = aws_key_pair.key_pair.key_name
  security_groups = [aws_security_group.sg.id]

  ebs_block_device {
    device_name = "/dev/sda1"
    delete_on_termination = true
    volume_size = 10
    volume_type = "gp2"
  }

  tags = {
    Name = "Jenkins"
  }
}

resource "aws_security_group" "sg" {
  name = "Jenkins-Allow-SSH-HTTP"
  description = "A security group that allows SSH and HTTP traffic."
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = var.ingress_http_allow
    description = "Allow HTTP traffic"
  }
    ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = var.ingress_ssh_allow
    description = "Allow SSH traffic"
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

# SSH Key
resource "tls_private_key" "instance" {
  algorithm = "RSA"
}

resource "aws_key_pair" "key_pair" {
  key_name   = var.name
  public_key = tls_private_key.instance.public_key_openssh
  tags = {
    Name = var.name
  }
}

# Secrets
resource "aws_secretsmanager_secret" "secret" {
  name = var.name
}

resource "aws_secretsmanager_secret_version" "secret_version" {
  secret_id     = aws_secretsmanager_secret.secret.id
  secret_string = tls_private_key.instance.private_key_pem
}
