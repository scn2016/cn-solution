#
# VPC Resources
#  * VPC
#  * Subnets
#  * Internet Gateway
#  * Route Table
#

resource "aws_vpc" "demo" {
  cidr_block = "10.0.0.0/16"

  tags = map(
    "Name", "terraform-eks-demo-node",
    "kubernetes.io/cluster/${var.cluster-name}", "shared",
  )
}

resource "aws_subnet" "demo" {
  count = 2

  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = "10.0.${count.index}.0/24"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.demo.id

  tags = map(
    "Name", "terraform-eks-demo-node",
    "kubernetes.io/cluster/${var.cluster-name}", "shared",
  )
}

resource "aws_internet_gateway" "demo" {
  vpc_id = aws_vpc.demo.id

  tags = {
    Name = "terraform-eks-demo"
  }
}

resource "aws_route_table" "demo" {
  vpc_id = aws_vpc.demo.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo.id
  }
}

resource "aws_route_table_association" "demo" {
  count = 2

  subnet_id      = aws_subnet.demo.*.id[count.index]
  route_table_id = aws_route_table.demo.id
}

resource "aws_subnet" "demo_private" {
  count = 2

  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = cidrsubnet(aws_vpc.demo.cidr_block, 8, 255-count.index)
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.demo.id

  tags = map(
    "Name", "terraform-eks-demo-node",
    "kubernetes.io/cluster/${var.cluster-name}", "shared",
  )


}

resource "aws_eip" "nat" {
  count = "1"
  vpc   = true

 tags = {
    Name = "terraform-eks-demo-eip"
  }


}

# ...and create a NAT gateway with the created IPs attatched
resource "aws_nat_gateway" "nat_gateway" {
  count         = "1"
  allocation_id = aws_eip.nat.*.id[count.index]
  subnet_id     = aws_subnet.demo.*.id[count.index]

 tags = {
    Name = "terraform-eks-demo-nat-gw"
  }

}

resource "aws_route_table" "demo_private" {
  vpc_id = aws_vpc.demo.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway[0].id
  }

}

resource "aws_route_table_association" "demo_private" {
  count = 2

  subnet_id      = aws_subnet.demo_private.*.id[count.index]
  route_table_id = aws_route_table.demo_private.id
}

