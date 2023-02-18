provider "aws" {
  access_key = ""
  secret_key = ""
  region = ""
}


resource "aws_instance" "jenkins" {
  ami = "ami-0574da719dca65348"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.open_ports_jenkins.id]
  key_name = "TF_key"
}

resource "aws_instance" "apache" {
  ami = "ami-0574da719dca65348"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.open_ports_apache.id]
  key_name = "TF_key"
}


resource "aws_security_group" "open_ports_jenkins" {
  name        = "open_ports_jenkins"
  description = "open_ports_jenkins"

  ingress {
    description = "Jenkins8080"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Jenkins_WebHook"
    from_port   = 50000
    to_port     = 50000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }


  tags = {
    Name = "open_ports_jenkins"
  }
}

resource "aws_security_group" "open_ports_apache" {
  name        = "open_ports_apache"
  description = "open_ports_apache"

  ingress {
    description = "Apache80"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }


  tags = {
    Name = "open_ports_apache"
  }
}


resource "aws_key_pair" "TF_key" {
  key_name   = "TF_key"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "TF-key" {
    content  = tls_private_key.rsa.private_key_pem
    filename = "tfkey"
}


output "instance_public_ip_jenkins" {
  description = "Public IP address of the jenkins instance"
  value       = aws_instance.jenkins.public_ip
}

output "instance_public_ip_apache" {
  description = "Public IP address of the apache instance"
  value       = aws_instance.apache.public_ip
}