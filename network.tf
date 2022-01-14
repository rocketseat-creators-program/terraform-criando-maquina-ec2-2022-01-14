#### BLOCO REDE

resource "aws_vpc" "ec-vpc" {
  cidr_block = "172.16.0.0/16"

}

resource "aws_subnet" "ec-subnet" {
  vpc_id     = aws_vpc.ec-vpc.id
  cidr_block = "172.16.10.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_network_interface" "ec-netint" {
  subnet_id       = aws_subnet.ec-subnet.id
  private_ips     = ["172.16.10.100"]
  security_groups = [aws_security_group.ec-secgroup.id]
}

resource "aws_internet_gateway" "ec-igw" {
  vpc_id = aws_vpc.ec-vpc.id
}

resource "aws_route_table" "ec-routetable" {
  vpc_id = aws_vpc.ec-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ec-igw.id
  }
}

resource "aws_route_table_association" "subnet-association" {
  subnet_id      = aws_subnet.ec-subnet.id
  route_table_id = aws_route_table.ec-routetable.id
}