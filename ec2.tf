provider "aws" {
region = "${var.region}"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}

resource "aws_instance" "myfirstec2"{
  ami = "ami-0565af6e282977273"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.instance.id}"]
  key_name = "skey"
  user_data = <<-EOF
              #!/bin/bash
              echo "Installing java and tomcat"
              apt-get update
              apt-get install -y default-jre
              apt-get install -y zip unzip
              apt-get install maven -y
              wget http://mirrors.estointernet.in/apache/tomcat/tomcat-8/v8.5.38/bin/apache-tomcat-8.5.38.zip
              mv apache-tomcat-8.5.38.zip /opt
              cd /opt
              unzip apache-tomcat-8.5.38.zip

              echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
              <!--
              Licensed to the Apache Software Foundation (ASF) under one or more
              contributor license agreements.  See the NOTICE file distributed with
              this work for additional information regarding copyright ownership.
              The ASF licenses this file to You under the Apache License, Version 2.0
              (the "License"); you may not use this file except in compliance with
              the License.  You may obtain a copy of the License at

                  http://www.apache.org/licenses/LICENSE-2.0

              Unless required by applicable law or agreed to in writing, software
              distributed under the License is distributed on an "AS IS" BASIS,
              WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
              See the License for the specific language governing permissions and
              limitations under the License.
              -->
              <tomcat-users xmlns=\"http://tomcat.apache.org/xml\"
                            xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"
                            xsi:schemaLocation=\"http://tomcat.apache.org/xml tomcat-users.xsd\"
                            version=\"1.0\">
              <!--
                NOTE:  By default, no user is included in the "manager-gui" role required
                to operate the "/manager/html" web application.  If you wish to use this app,
                you must define such a user - the username and password are arbitrary. It is
                strongly recommended that you do NOT use one of the users in the commented out
                section below since they are intended for use with the examples web
                application.
               -->
               <!--
                 NOTE:  The sample user and role entries below are intended for use with the
                 examples web application. They are wrapped in a comment and thus are ignored
                 when reading this file. If you wish to configure these users for use with the
                 examples web application, do not forget to remove the <!.. ..> that surrounds
                 them. You will also need to set the passwords to something appropriate.
               -->
                 <role rolename=\"manager-gui\"/>
                 <user username=\"tomcat\" password=\"tomcat\" roles=\"manager-gui\"/>
                 </tomcat-users>"  > /opt/apache-tomcat-8.5.38/conf/tomcat-users.xml
               echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
               <!--
                 Licensed to the Apache Software Foundation (ASF) under one or more
                 contributor license agreements.  See the NOTICE file distributed with
                 this work for additional information regarding copyright ownership.
                 The ASF licenses this file to You under the Apache License, Version 2.0
                 (the "License"); you may not use this file except in compliance with
                 the License.  You may obtain a copy of the License at

                     http://www.apache.org/licenses/LICENSE-2.0

                 Unless required by applicable law or agreed to in writing, software
                 distributed under the License is distributed on an "AS IS" BASIS,
                 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
                 See the License for the specific language governing permissions and
                 limitations under the License.
                 -->
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
