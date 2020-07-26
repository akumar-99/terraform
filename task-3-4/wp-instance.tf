resource "aws_security_group" "wp" {
  name        = "wp-httpd"
  description = "wp sql connection and egress"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "wp-httpd"
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "wp" {
  ami             = "ami-0732b62d310b80e97" #Amazon Linux 2 AMI (HVM), SSD Volume Type
  instance_type   = "t2.micro"
  key_name        = aws_key_pair.webserver_key.key_name
  vpc_security_group_ids = [aws_security_group.wp.id]
  subnet_id       = aws_subnet.public.id
  
  tags = {
    Name = "wp"
  }
}

resource "null_resource" "wp_setup" {
  connection {
    type        = "ssh"
    user        = "ec2-user"
    host        = aws_instance.wp.public_ip
    port        = 22
    private_key = tls_private_key.webserver_key.private_key_pem
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2",
      "sudo yum install -y httpd php-gd",
      "wget https://wordpress.org/latest.tar.gz",
      "tar -xzf latest.tar.gz",
      "cp wordpress/wp-config-sample.php wordpress/wp-config.php",
      "sed -i 's/database_name_here/wordpress_db/g' wordpress/wp-config.php",
      "sed -i 's/username_here/wordpress-user/g' wordpress/wp-config.php",
      "sed -i 's/password_here/password@123/g' wordpress/wp-config.php",
      "sed -i 's/localhost/${aws_instance.sql.private_ip}/g' wordpress/wp-config.php",
      "sudo cp -r wordpress/* /var/www/html/",
      "sudo chown -R apache /var/www",
      "sudo chgrp -R apache /var/www",
      "sudo chmod 2775 /var/www",
      "sudo sed -i  '151s/.*/AllowOverride All/' httpd.conf",
      "sudo systemctl start httpd",
      "sudo systemctl enable httpd"
    ]
  }
}