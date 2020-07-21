output "lb" {
  value = aws_lb.test.dns_name
}

output "cdn" {
  value = "http://${aws_cloudfront_distribution.s3_distribution.domain_name}/${aws_s3_bucket_object.image-upload.key}"
}