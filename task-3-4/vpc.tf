resource "aws_vpc" "main" {
  cidr_block            = "192.168.0.0/16"
  enable_dns_support    = true
  enable_dns_hostnames  = true
  tags = {
    "Name" = var.vpc-name
  }
}

resource "aws_subnet" "public" {
  cidr_block              = "192.168.0.0/24"
  availability_zone       = "${var.availability-zone}"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.main.id
  tags = {
    "Name" = "${var.vpc-name}-public"
  }
}

resource "aws_subnet" "private" {
  cidr_block              = "192.168.1.0/24"
  availability_zone       = "${var.availability-zone}"
  map_public_ip_on_launch = false
  vpc_id = aws_vpc.main.id
  tags = {
    "Name" = "${var.vpc-name}-private"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    "Name" = "${var.vpc-name}-igw"
  }
}

resource "aws_eip" "ngw" {
  tags = {
    "Name" = "${var.vpc-name}-eip-ngw"
  }
}

resource "aws_nat_gateway" "gw" {
  allocation_id = aws_eip.ngw.id
  subnet_id     = aws_subnet.public.id
  tags = {
    "Name" = "${var.vpc-name}-ngw"
  }
}

resource "aws_route_table" "secondary_table" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    "Name" = "custom-igw-table"
  }
}

resource "aws_route_table_association" "public_custom" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.secondary_table.id
}

resource "aws_default_route_table" "main_table" {
  default_route_table_id = aws_vpc.main.main_route_table_id
  route {
    cidr_block      = "0.0.0.0/0"
    nat_gateway_id  = aws_nat_gateway.gw.id
  }
  tags = {
    "Name" = "main-ngw-table"
  }
}

resource "aws_route_table_association" "private_custom" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_default_route_table.main_table.id
}
