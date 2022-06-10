resource "aws_vpc" "newvpc" {
  cidr_block       = var.network_cidr

  tags = {
    Name = "newvpc"
  }
}

resource "aws_internet_gateway" "newigw" {
  vpc_id = aws_vpc.newvpc.id

  tags = {
    Name = "newigw"
  }
}


resource "aws_s3_bucket" "mys3bucket" {
  bucket = var.bucket_name
  tags = {
    "Name" = "new S3bucket"
  }
}


# for (i=0 ; i < 6 ; i++){
#     resource "aws_subnet" "subnets" {
#         cidr_block = var.subnet_cird[i]
#         availability_zone = var.subnet_azs[i]
#         vpc_id     = aws_vpc.newvpc.id
#         tags = {
#             Name = var.subnet_name_tags[i]
#         }
#     }
# }


resource "aws_subnet" "subnets" {
  count = length(var.subnet_name_tags)
  vpc_id     = aws_vpc.newvpc.id
  cidr_block = cidrsubnet(var.network_cidr,8,count.index)
#   availability_zone = var.subnet_azs[count.index]
  availability_zone = format("${var.region}%s", count.index%2==0?"a":"b")

  tags = {
    Name = var.subnet_name_tags[count.index]
  }
}

resource "aws_security_group" "websg" {
  vpc_id = aws_vpc.newvpc.id
  description = "created by terraform"
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name             = "Web Sg"

  }
}

resource "aws_security_group" "appsg" {
  vpc_id = aws_vpc.newvpc.id
  description = "app security group from tf"
  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    "Name"            = "App Sg"
  }
  
}

resource "aws_security_group" "dbsg" {
  vpc_id = aws_vpc.newvpc.id
  description = "db sg from tf"
  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    "Name" = "DB Sg"
  }
}