data "aws_region" "current" {
}

data "aws_availability_zones" "available" {
  state = "available"
  filter {
    name = "zone-type"
    values = ["availability-zone"]
  }
}

resource "aws_vpc" "k8s-acc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    "Name"                                        = "terraform-eks-k8s-${var.cluster_name}-node"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "Owner"                                     = "${var.owner}"
  }
}

resource "aws_subnet" "k8s-acc" {
  count = 2

  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = "10.0.${count.index}.0/24"
  vpc_id                  = aws_vpc.k8s-acc.id
  map_public_ip_on_launch = true

  tags = {
    "Name"                                      = "terraform-eks-${var.cluster_name}-node"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = 1
    "Owner"                                     = "${var.owner}"
  }
}

resource "aws_internet_gateway" "k8s-acc" {
  vpc_id = aws_vpc.k8s-acc.id

  tags = {
    Name = "terraform-eks-${var.cluster_name}-gateway"
    "Owner" = "${var.owner}"
  }
}

resource "aws_route_table" "k8s-acc" {
  vpc_id = aws_vpc.k8s-acc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.k8s-acc.id
  }
}

resource "aws_route_table_association" "k8s-acc" {
  count = 2

  subnet_id      = aws_subnet.k8s-acc[count.index].id
  route_table_id = aws_route_table.k8s-acc.id
}


