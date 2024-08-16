provider "aws" {
  region = "us-west-2"
}

data "local_file" "packer_manifest" {
  filename = "manifest.json"
}

resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow HTTP traffic"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
  ami           = split(":", jsondecode(data.local_file.packer_manifest.content)["builds"][0]["artifact_id"])[1]
  instance_type = "t2.micro"

  tags = {
    Name = "nginx-web-server"
  }

  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              sudo systemctl start nginx
              EOF
}

# output instance id
output "instance_id" {
  value       = aws_instance.web.id
  description = "ID of the EC2 instance"
}
