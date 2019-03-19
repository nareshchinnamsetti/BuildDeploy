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
              echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
              <tomcat-users xmlns=\"http://tomcat.apache.org/xml\"
                            xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"
                            xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"
                            version=\"1.0\">
              <role rolename=\"manager-gui\"/>
              <role rolename=\"manager-script\"/>
              <user username=\"tomcat\" password=\"tomcat\" roles=\"manager-script,manager-gui\"/>
              </tomcat-users>"  > /opt/apache-tomcat-8.5.38/conf/tomcat-users.xml
              echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
              <Context antiResourceLocking=\"false\" privileged=\"true\" >
                <Manager sessionAttributeValueClassNameFilter=\"java\.lang\.(?:Boolean|Integer|Long|Number|String)|org\.apache\.catalina\.filters\.CsrfPreventionFilter\$LruCache(?:\$1)?|java\.util\.(?:Linked)?HashMap\"/>
              </Context>" > /opt/apache-tomcat-8.5.38/webapps/manager/META-INF/context.xml
              git clone https://github.com/efsavage/hello-world-war.git
              cd hello-world-war/
              mvn package
              cd target
              cp hello-world-war-1.0.0.war /opt/apache-tomcat-8.5.38/webapps
              chmod +x /opt/apache-tomcat-8.5.38/bin/catalina.sh
              chmod +x /opt/apache-tomcat-8.5.38/bin/startup.sh
              sh /opt/apache-tomcat-8.5.38/bin/startup.sh
              EOF

  tags { 
    Name = "tommy"

  }
}


resource "aws_security_group" "instance" {
  name = "tommy-security-group"
  
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
