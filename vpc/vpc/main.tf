#tfsec:ignore:require-vpc-flow-logs-for-all-vpcs
resource "aws_vpc" "main" {
  cidr_block = var.cidr_block
  tags       = var.tags
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = var.tags
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = var.tags
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  # route {
  #   cidr_block = "10.0.0.0/24"
  #   gateway_id = aws_internet_gateway.main.id
  # }

  tags = var.tags
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "private_subnet_1" {
  source     = "./subnet"
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.0.0/24"
  tags = {
    Name    = "Private Subnet 1"
    Project = "Virtual Private Cloud"
  }
  availability_zone = data.aws_availability_zones.available.names[0]
}

module "private_subnet_2" {
  source     = "./subnet"
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name    = "Private Subnet 2"
    Project = "Virtual Private Cloud"
  }
  availability_zone = data.aws_availability_zones.available.names[1]
}

#tfsec:ignore:no-public-ip-subnet
module "public_subnet_1" {
  source     = "./subnet"
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  tags = {
    Name    = "Public Subnet 1"
    Project = "Virtual Private Cloud"
  }
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
}

resource "aws_route_table_association" "public_subnet_1" {
  subnet_id      = module.public_subnet_1.subnet_id
  route_table_id = aws_route_table.public.id
}

#tfsec:ignore:no-public-ip-subnet
module "public_subnet_2" {
  source     = "./subnet"
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.3.0/24"
  tags = {
    Name    = "Public Subnet 2"
    Project = "Virtual Private Cloud"
  }
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true
}

resource "aws_route_table_association" "public_subnet_2" {
  subnet_id      = module.public_subnet_2.subnet_id
  route_table_id = aws_route_table.public.id
}
