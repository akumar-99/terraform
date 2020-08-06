resource "aws_security_group" "sql" {
  name        = "mariabdb-sql"
  description = "wp sql connection and egress"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "mariadb-sql"
    from_port   = 3306
    to_port     = 3306
    protocol    = "TCP"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  # ingress {
  #   description = "ssh"
  #   from_port   = 22
  #   to_port     = 22
  #   protocol    = "TCP"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "sql" {
  ami             = "ami-0732b62d310b80e97" #Amazon Linux 2 AMI (HVM), SSD Volume Type
  instance_type   = "t2.micro"
  key_name        = aws_key_pair.webserver_key.key_name
  vpc_security_group_ids = [aws_security_group.sql.id]
  subnet_id       = aws_subnet.private.id
  user_data       = <<EOT
  #!/bin/bash
  sudo yum update -y
  sudo amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2
  sudo yum install -y mariadb-server
  sudo systemctl start mariadb
  sudo systemctl enable mariadb
  mysql -u root <<EOF
  CREATE USER 'wordpress-user'@'${aws_instance.wp.private_ip}' IDENTIFIED BY 'password@123';
  CREATE DATABASE wordpress_db;
  GRANT ALL PRIVILEGES ON wordpress_db.* TO 'wordpress-user'@'${aws_instance.wp.private_ip}';
  FLUSH PRIVILEGES;
  exit
  EOF
  EOT


  
  tags = {
    Name = "sql"
  }
}