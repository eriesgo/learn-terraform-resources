provider "aws" {
  region  = "us-west-2"
  profile = "quique"
}

provider "random" {}

resource "random_pet" "name" {}

resource "aws_instance" "web" {
  ami           = "ami-a0cfeed8"
  instance_type = "t2.micro"
  user_data     = file("init-script.sh")

  tags = {
    Name = random_pet.name.id
  }

  # Added security group for port 80
  vpc_security_group_ids = [aws_security_group.web_sg.id]
}

resource "aws_security_group" "web_sg" {
  # Name is based in random_pet
  name        = "${random_pet.name.id}-sg"
  description = "Allow HTTP incoming traffic for ${random_pet.name.id}"

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}