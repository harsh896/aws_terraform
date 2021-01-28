#----------------------------------- VPC----------------------------------------
resource "aws_vpc" "main" {
  cidr_block       = var.VpcCIDR
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.EnvironmentName}-VPC"
    "kubernetes.io/cluster/${local.clusterName}" =  "shared"
  }
}

#----------------------------Internet Gateway----------------------------------

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.EnvironmentName}-Internet-Gateway"
    "kubernetes.io/cluster/${local.clusterName}" =  "shared"
  }
}


#-----------------------Subnets-----------------------------
locals {
  subnetCIDRValue = 2
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = cidrsubnet(aws_vpc.main.cidr_block, local.subnetCIDRValue, 0)
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "${var.EnvironmentName}-Public-Subnet-1"
    "kubernetes.io/cluster/${local.clusterName}" =  "shared"
  }
}
resource "aws_subnet" "public_subnet_2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = cidrsubnet(aws_vpc.main.cidr_block, local.subnetCIDRValue, 1)
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "${var.EnvironmentName}-Public-Subnet-2"
    "kubernetes.io/cluster/${local.clusterName}" =  "shared"
  }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = cidrsubnet(aws_vpc.main.cidr_block, local.subnetCIDRValue, 2)
  map_public_ip_on_launch = false
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "${var.EnvironmentName}-Private-Subnet-1"
    "kubernetes.io/cluster/${local.clusterName}" =  "shared"
  }
}
resource "aws_subnet" "private_subnet_2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = cidrsubnet(aws_vpc.main.cidr_block, local.subnetCIDRValue, 3)
  map_public_ip_on_launch = false
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "${var.EnvironmentName}-Private-Subnet-2"
    "kubernetes.io/cluster/${local.clusterName}" =  "shared"
  }
}


#------------------------------------_Elastic Ips-----------------------------------------------------------
resource "aws_eip" "nat_gateway_1_eip" {
  vpc      = true
  tags = {
    Name = "${var.EnvironmentName}-EIP-1"
    "kubernetes.io/cluster/${local.clusterName}" =  "shared"
  }
}
resource "aws_eip" "nat_gateway_2_eip" {
  vpc      = true
  tags = {
    Name = "${var.EnvironmentName}-EIP-2"
    "kubernetes.io/cluster/${local.clusterName}" =  "shared"
  }
}
#----------------------------------- Nat Gateways --------------------------------------------------------------
resource "aws_nat_gateway" "nat_gw_1" {
  allocation_id = aws_eip.nat_gateway_1_eip.id
  subnet_id     = aws_subnet.public_subnet_1.id
  tags = {
    Name = "${var.EnvironmentName}-NatGateway-1"
    "kubernetes.io/cluster/${local.clusterName}" =  "shared"
  }
}

resource "aws_nat_gateway" "nat_gw_2" {
  allocation_id = aws_eip.nat_gateway_2_eip.id
  subnet_id     = aws_subnet.public_subnet_2.id
  tags = {
    Name = "${var.EnvironmentName}-NatGateway-2"
    "kubernetes.io/cluster/${local.clusterName}" =  "shared"
  }
}

#------------------------------------Route Table------------------------------------------------------
#--------Public------------
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.EnvironmentName} Public Route"
    "kubernetes.io/cluster/${local.clusterName}" =  "shared"
  }
}
resource "aws_route_table_association" "public_subnet_rtb_assoc_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}
resource "aws_route_table_association" "public_subnet_rtb_assoc_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}
#--------Private-1------------
resource "aws_route_table" "private_route_table_1" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gw_1.id
  }
  tags = {
    Name = "${var.EnvironmentName} Private Route 1"
    "kubernetes.io/cluster/${local.clusterName}" =  "shared"
  }
}
resource "aws_route_table_association" "private_subnet_rtb_assoc_1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_route_table_1.id
}
#--------Private-1------------
resource "aws_route_table" "private_route_table_2" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gw_2.id
  }
  tags = {
    Name = "${var.EnvironmentName} Private Route 2"
    "kubernetes.io/cluster/${local.clusterName}" =  "shared"
  }
}
resource "aws_route_table_association" "private_subnet_rtb_assoc_2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_route_table_2.id
}

#--------------------------Security Group---------------------------------------------

resource "aws_security_group" "allow-all" {
  name        = "${var.EnvironmentName} Security Group"
  description = "Allow Traffic for ${var.EnvironmentName}"
  vpc_id      = aws_vpc.main.id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.EnvironmentName} Security Group"
    "kubernetes.io/cluster/${local.clusterName}" =  "shared"
  }
}