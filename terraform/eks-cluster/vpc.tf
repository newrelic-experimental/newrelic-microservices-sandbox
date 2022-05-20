data "aws_region" "current" {
}

data "aws_availability_zones" "available" {
  state = "available"
  filter {
    name = "zone-type"
    values = ["availability-zone"]
  }
}

resource "aws_vpc" "nr_sandbox" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

resource "aws_subnet" "nr_sandbox" {
  count = 2

  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = "10.0.${count.index}.0/24"
  vpc_id                  = aws_vpc.nr_sandbox.id
  map_public_ip_on_launch = true

  tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = 1
  }
}

resource "aws_internet_gateway" "nr_sandbox" {
  vpc_id = aws_vpc.nr_sandbox.id
}

resource "aws_route_table" "nr_sandbox" {
  vpc_id = aws_vpc.nr_sandbox.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.nr_sandbox.id
  }
}

resource "aws_route_table_association" "nr_sandbox" {
  count = 2

  subnet_id      = aws_subnet.nr_sandbox[count.index].id
  route_table_id = aws_route_table.nr_sandbox.id
}
