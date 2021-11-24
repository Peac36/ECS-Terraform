// fetch all AZ so we can spread resources evenly
data "aws_availability_zones" "zones" {}


resource "aws_vpc" "main" {
  cidr_block = module.env.CIDR
  enable_dns_hostnames = true
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index + 1)
  availability_zone_id = data.aws_availability_zones.zones.zone_ids[count.index]
  count = module.env.AvailabilityZoneCount
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 8, 3 + count.index)
  availability_zone_id = data.aws_availability_zones.zones.zone_ids[count.index]
  count = module.env.AvailabilityZoneCount
}

resource "aws_internet_gateway" "internet" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public_router_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet.id
  }
}

resource "aws_route_table" "private_router_table" {
  count = module.env.AvailabilityZoneCount
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.gw.*.id, count.index)
  }
}

resource "aws_route_table_association" "public_table_association" {
    subnet_id      = aws_subnet.public[count.index].id
    route_table_id = aws_route_table.public_router_table.id
    count = module.env.AvailabilityZoneCount
}

resource "aws_route_table_association" "private_table_association" {
    subnet_id      = aws_subnet.private[count.index].id
    route_table_id = aws_route_table.private_router_table[count.index].id
    count = module.env.AvailabilityZoneCount
}

resource "aws_eip" "nat_ip" {
  vpc = true
  count = module.env.AvailabilityZoneCount
}

resource "aws_nat_gateway" "gw" {
  allocation_id = aws_eip.nat_ip[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  count = module.env.AvailabilityZoneCount
}