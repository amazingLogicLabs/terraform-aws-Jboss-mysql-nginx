provider "aws" {
  access_key = "XXXXXXXXXX"
  secret_key = "XXXXXXXXXX"
  region = "us-west-2"
}

resource "aws_key_pair" "deployer" {
  key_name   = "newTest"
  public_key = "ssh-rsa "
}

resource "aws_instance" "example" {
  ami = "ami-f2d3638a"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.instance.id}"]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              yum update -y
              yum install -y nginx >> /tmp/install.log
              yum install -y openjdk-7-jdk >> /tmp/install.log

              cd /tmp
              wget http://download.jboss.org/jbossas/7.1/jboss-as-7.1.1.Final/jboss-as-7.1.1.Final.tar.gz
              tar xfvz jboss-as-7.1.1.Final.tar.gz
              mv jboss-as-7.1.1.Final /usr/local/share/jboss
              adduser appserver
              chown -R appserver /usr/local/share/jboss

              echo "Completed Install." >> /tmp/install.log

              # Start the JBoss server
              su - appserver -c '/usr/local/share/jboss/bin/standalone.sh -Djboss.bind.address=0.0.0.0 -Djboss.bind.address.management=0.0.0.0 &'yum update -y

              EOF

  tags {
    Name = "terraform-example"
  }
}

resource "aws_security_group" "instance" {
  name = "terraform-example-instance"

  # Inbound HTTP from anywhere
  ingress {
    from_port = "${var.server_port}"
    to_port = "${var.server_port}"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
