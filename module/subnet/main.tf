resource "aws_subnet" "mk-app-subnet" {
    vpc_id     = var.vpc_id
    cidr_block = "10.0.0.0/24"
    availability_zone = var.availability_zone
    tags = {
        Name: "${var.env_prefix}-subnet-1"
    }
}

resource "aws_internet_gateway" "myapp-igw" {
    vpc_id = "vpc-5b3a0d32"
    tags = {
        Name: "${var.env_prefix}-igw"
    }
  
}
resource "aws_route_table" "my-app-route-table" {
    vpc_id = "vpc-5b3a0d32"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.myapp-igw.id
    }
    tags = {
        Name: "${var.env_prefix}-rtb"
    }
}

resource "aws_route_table_association" "a-rtb-subnet" {
    subnet_id = aws_subnet.mk-app-subnet.id
    route_table_id = "rtb-0dc8ecafc502f8a95"
}