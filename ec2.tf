provider "aws" {
region = "${var.region}"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}

resource "aws_instance" "myfirstec2"{
  ami = "ami-0653e888ec96eab9b"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.instance.id}"]
  key_name = "aws"
  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y default-jre
              apt-get install -y zip unzip
              apt-get install maven -y
              wget http://mirrors.estointernet.in/apache/tomcat/tomcat-8/v8.5.38/bin/apache-tomcat-8.5.38.zip
              mv apache-tomcat-8.5.38.zip /opt
              cd /opt
              unzip apache-tomcat-8.5.38.zip
              EOF

  tags { 
    Name = "Tom"

  }
}


resource "aws_security_group" "instance" {
  name = "tom-security-group"
  
  # Inbound tomcat from anywhere
  ingress { 
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0 
    to_port = 0 
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
}
