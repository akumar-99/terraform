# Elastic File System

resource "aws_security_group" "demo-efs" {
  depends_on = [
    aws_security_group.webserver_sg,
  ]
  name        = "efs"
  description = "Communication to efs"
  vpc_id      = data.aws_vpc.selected.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.webserver_sg.id]
  }
}

resource "aws_efs_file_system" "demo" {
  depends_on = [
    aws_security_group.demo-efs
  ]
  creation_token = "efs"
  tags = {
    Name = "WebServer"
  }
}

resource "aws_efs_mount_target" "demo" {
  depends_on = [
    aws_efs_file_system.demo
  ]
  for_each        = data.aws_subnet_ids.example.ids
  file_system_id  = aws_efs_file_system.demo.id
  subnet_id       = each.value
  security_groups = ["${aws_security_group.demo-efs.id}"]
}

resource "aws_efs_access_point" "demo" {
  depends_on = [
    aws_efs_file_system.demo
  ]
  file_system_id = aws_efs_file_system.demo.id
}

resource "null_resource" "mount_webserver1" {
  depends_on = [
    aws_efs_file_system.demo,
    aws_efs_mount_target.demo,
    aws_efs_access_point.demo,
    aws_instance.webserver_1,
  ]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    host        = aws_instance.webserver_1.public_ip
    port        = 22
    private_key = tls_private_key.webserver_key.private_key_pem
  }

  provisioner "remote-exec" {
    inline = [
      "sudo su << EOF",
      "git clone https://github.com/aws/efs-utils",
      "yum install make rpm-build -y",
      "make rpm --directory=./efs-utils",
      "yum install ./efs-utils/build/amazon-efs-utils*rpm -y",
      "echo \"${aws_efs_file_system.demo.id} /var/www/html efs _netdev,tls,accesspoint=${aws_efs_access_point.demo.id} 0 0\" > /etc/fstab",
      "mount -a",
      "rm -rf /var/www/html/*",
      "git clone https://github.com/devil-test/webserver-test.git /var/www/html",
      "chmod 777 /var/www/html/*",
      "setenforce 0",
      "EOF"
    ]
  }
}

resource "null_resource" "mount_webserver2" {
  depends_on = [
    aws_efs_file_system.demo,
    aws_efs_mount_target.demo,
    aws_efs_access_point.demo,
    aws_instance.webserver_2
  ]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    host        = aws_instance.webserver_2.public_ip
    port        = 22
    private_key = tls_private_key.webserver_key.private_key_pem
  }

  provisioner "remote-exec" {
    inline = [
      "sudo su << EOF",
      "git clone https://github.com/aws/efs-utils",
      "yum install make rpm-build -y",
      "make rpm --directory=./efs-utils",
      "yum install ./efs-utils/build/amazon-efs-utils*rpm -y",
      "echo \"${aws_efs_file_system.demo.id} /var/www/html efs _netdev,tls,accesspoint=${aws_efs_access_point.demo.id} 0 0\" > /etc/fstab",
      "mount -a",
      "setenforce 0",
      "EOF"
    ]
  }
}
