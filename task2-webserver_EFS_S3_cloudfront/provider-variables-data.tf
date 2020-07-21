# AWS Provider
provider "aws" {
  profile = "ashish-college"
  region  = "ap-south-1"
}

# Get default VPC of account
data "aws_vpc" "selected" {
  default = true
}

# Get live availability zones list
data "aws_availability_zones" "available" {
  state = "available"
}

# Get the list of subnet ids in selected VPC
data "aws_subnet_ids" "example" {
  vpc_id = data.aws_vpc.selected.id
}

# data "aws_subnet" "example" {
#   for_each = data.aws_subnet_ids.example.ids
#   id       = each.value
# }

# output "subnet_cidr_blocks" {
#   value = [for s in data.aws_subnet.example : s.cidr_block]
# }

