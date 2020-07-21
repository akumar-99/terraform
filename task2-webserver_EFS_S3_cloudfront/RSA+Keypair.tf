# Generates RSA Keypair
resource "tls_private_key" "webserver_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save Private key locally
resource "local_file" "private_key" {
  depends_on = [
    tls_private_key.webserver_key,
  ]
  content  = tls_private_key.webserver_key.private_key_pem
  filename = "webserver.pem"
}

# Upload public key to create keypair on AWS
resource "aws_key_pair" "webserver_key" {
  depends_on = [
    tls_private_key.webserver_key,
  ]
  key_name   = "webserver"
  public_key = tls_private_key.webserver_key.public_key_openssh
}
