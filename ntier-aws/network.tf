resource "aws_vpc" "newvpc" {
  cidr_block        = var.network_cidr

  tags = {
    Name            = "newvpc"
  }
}

resource "aws_internet_gateway" "newigw" {
  vpc_id            = aws_vpc.newvpc.id

  tags = {
    Name            = "newigw"
  }
}

resource "aws_subnet" "subnets" {
  count             = length(var.subnet_name_tags)
  vpc_id            = aws_vpc.newvpc.id
  cidr_block        = cidrsubnet(var.network_cidr,8,count.index)
#   availability_zone = var.subnet_azs[count.index]
  availability_zone = format("${var.region}%s", count.index%2==0?"a":"b")

  tags = {
    Name            = var.subnet_name_tags[count.index]
  }
}

resource "aws_security_group" "websg" {
  vpc_id            = aws_vpc.newvpc.id
  description       = local.default_description
  ingress {
    from_port       = local.ssh_port
    to_port         = local.ssh_port
    protocol        = local.tcp
    cidr_blocks     = [local.any_where]
  }

  ingress {
    from_port       = local.http_port
    to_port         = local.http_port
    protocol        = local.tcp
    cidr_blocks     = [local.any_where]
  }

  egress {
    from_port        = local.all_ports
    to_port          = local.all_ports
    protocol         = local.any_protocol
    cidr_blocks      = [local.any_where]
    ipv6_cidr_blocks = [local.any_where_ipv6]
  }
  tags = {
    Name             = "Web Sg"

  }
}

resource "aws_security_group" "appsg" {
  vpc_id              = aws_vpc.newvpc.id
  description         = local.default_description
  ingress {
    from_port         = local.ssh_port
    to_port           = local.ssh_port
    protocol          = local.tcp
    cidr_blocks       = [local.any_where]
  }

  ingress {
    from_port         = local.app_port
    to_port           = local.app_port
    protocol          = local.tcp
    cidr_blocks       = [local.any_where]
  }

  egress {
    from_port         = local.all_ports
    to_port           = local.all_ports
    protocol          = local.any_protocol
    cidr_blocks       = [local.any_where]
    ipv6_cidr_blocks  = [local.any_where_ipv6]
  }
  tags = {
    "Name"            = "App Sg"
  }
  
}

resource "aws_route_table" "publicrt" {
  vpc_id = aws_vpc.newvpc.id
  route {
    cidr_block = local.any_where
    gateway_id = aws_internet_gateway.newigw.id
  }
  tags = {
    "Name" = "Public RT"
  }
  
}

resource "aws_route_table" "privatert" {
  vpc_id = aws_vpc.newvpc.id
  tags = {
    "Name" = "Private RT"
  }
  
}

# Subnet association

resource "aws_route_table_association" "association" {
  count = length(aws_subnet.subnets)
  subnet_id = aws_subnet.subnets[count.index].id
  route_table_id = contains(var.Public_subnets, lookup(aws_subnet.subnets[count.index].tags_all, "Name", ""))? aws_route_table.publicrt.id : aws_route_table.privatert.id
  
}