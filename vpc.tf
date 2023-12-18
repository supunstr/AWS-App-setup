#######
# VPC #
#######

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"

  tags = {
    Name      = var.vpc_name
    Project   = var.project
    ManagedBy = "Terraform"
  }
}

############################
# Subnets for VPC internal #
############################

resource "aws_subnet" "this" {
  count                   = length(var.subnets)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = element(values(var.subnets), count.index).subnet_cidr_block
  availability_zone       = element(values(var.subnets), count.index).subnet_availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project}_${element(values(var.subnets), count.index).subnet_name}"
  }
}

####################
# Internet Gateway #
####################

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = {
    Name = "${var.project}-INTERNET-GW"
  }
}
#################
# Routing Table #
#################

resource "aws_route_table" "this" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "${var.project}-Public-Routing_table"
  }
}

resource "aws_main_route_table_association" "this" {
  vpc_id         = aws_vpc.this.id
  route_table_id = aws_route_table.this.id
}