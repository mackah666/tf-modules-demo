terraform {
  required_version = ">= 0.12, < 0.13"
}

provider "aws" {
  profile    = "default"
  region     = "eu-west-2"
  # Allow any 2.x version of the AWS provider
  version = "~> 2.0"
}
locals {
  common_tags = "${map(
    "Name", "terraform-example",
    "environment", "development",
    "owner", "macxkah666"
  )}"
}

resource "aws_security_group" "instance" {
  name = "terraform-example-instance"

  ingress {
    from_port = 8585
    to_port = 8585
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
}


resource "aws_instance" "example" {
  ami           = "ami-0b1912235a9e70540"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.instance.id}"]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, world" > index.html
              nohup busybox httpd -f -p 8585 &
              EOF

  tags = local.common_tags
  
}
