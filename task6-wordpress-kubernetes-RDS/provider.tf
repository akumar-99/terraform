provider "aws" {
  profile = "ashish-college"
  region  = "ap-south-1"
}

data "aws_vpc" "selected" {
  default = true
}

data "aws_subnet_ids" "example" {
  vpc_id = data.aws_vpc.selected.id
}

provider "kubernetes" {
  load_config_file = "false"

  host                   = "https://192.168.99.120:8443"
  client_certificate     = "${file("C:\\Users\\ashis\\.minikube\\profiles\\minikube\\client.crt")}"
  client_key             = "${file("C:\\Users\\ashis\\.minikube\\profiles\\minikube\\client.key")}"
  cluster_ca_certificate = "${file("C:\\Users\\ashis\\.minikube\\ca.crt")}"
}

# output "name" {
#   value = data.aws_vpc.selected.id
# }

# output "name1" {
#   value = data.aws_subnet_ids.example.ids
# }


