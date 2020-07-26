provider "aws" {
  profile = var.profile
  region  = var.region
}

data "aws_availability_zones" "available" {
  state = "available"
}