provider "aws" {
    region = "us-west-1"
 }

resource "aws_vpc" "mk-tf-vpc" {
    cidr_block = "192.0.0.0/16"
}

resource "aws_subnet" "mk-tf-subnet" {
    vpc_id     = aws_vpc.mk-tf-vpc.id
    cidr_block = "192.0.0.0/24"
    availability_zone = "us-west-1b"
    tags = {
        Name: "mk-tf-subnet"
    }
}

data "aws_vpc" "existing_vpc" {
    default= true
}
output "mk-tf-vpc-id" {
    value = aws_vpc.mk-tf-vpc.id  
}