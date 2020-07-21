resource "aws_s3_bucket" "image-bucket" {
  bucket = "webserver-images-test-123"
  acl    = "public-read"

  provisioner "local-exec" {
    command     = "git clone https://github.com/devil-test/webserver-image webserver-image"
    interpreter = ["PowerShell", "-Command"]
  }

  provisioner "local-exec" {
    when        = destroy
    command     = "Remove-Item  webserver-image -Recurse -Force"
    interpreter = ["PowerShell", "-Command"]
  }
}

resource "aws_s3_bucket_object" "image-upload" {
  depends_on = [
    aws_s3_bucket.image-bucket
  ]
  bucket = aws_s3_bucket.image-bucket.bucket
  key    = "myphoto.jpeg"
  source = "webserver-image/StudentPhoto.jpg"
  acl    = "public-read"
}

variable "var1" { default = "S3-" }

locals {
  s3_origin_id = "${var.var1}${aws_s3_bucket.image-bucket.bucket}"
  image_url    = "${aws_cloudfront_distribution.s3_distribution.domain_name}/${aws_s3_bucket_object.image-upload.key}"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  depends_on = [
    aws_instance.webserver_1,
    aws_instance.webserver_2,
    aws_s3_bucket.image-bucket
  ]
  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    viewer_protocol_policy = "allow-all"
  }

  enabled = true

  origin {
    domain_name = aws_s3_bucket.image-bucket.bucket_domain_name
    origin_id   = local.s3_origin_id
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

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
      "echo \"<img src='http://${self.domain_name}/${aws_s3_bucket_object.image-upload.key}'>\" >> /var/www/html/test.html",
      "EOF"
    ]
  }
}