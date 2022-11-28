provider "aws" {
    region= "eu-west-3"
}
variable "vpc_cidr_block" {}
variable "subnet_cidr_block" {}
variable "availability_zone" {}
variable "env_prefix" {}
variable "my_ip" {}
variable "instance_type" {}
variable "public_key_location" {}

resource "aws_vpc" "mk-app-vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name: "${var.env_prefix}-vpc"
    }
}

resource "aws_subnet" "mk-app-subnet" {
    vpc_id     = aws_vpc.mk-app-vpc.id
    cidr_block = var.subnet_cidr_block
    availability_zone = var.availability_zone
    tags = {
        Name: "${var.env_prefix}-subnet-1"
    }
}

resource "aws_internet_gateway" "myapp-igw" {
    vpc_id = aws_vpc.mk-app-vpc.id
    tags = {
        Name: "${var.env_prefix}-igw"
    }
  
}
resource "aws_route_table" "my-app-route-table" {
    vpc_id = aws_vpc.mk-app-vpc.id

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
    route_table_id = aws_route_table.my-app-route-table.id
}

resource "aws_security_group" "my-app-sg" {
    name = "my-app-sg"
    vpc_id = aws_vpc.mk-app-vpc.id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [var.my_ip]
    }
    
    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        prefix_list_ids = []
    }  

    tags = {
        name: "${var.env_prefix}-sg" 
    }  
}

data "aws_ami" "latest-amazon-linux-image" {
    most_recent = true
    owners = ["amazon"]
    filter {
        name = "name"
        values = ["amzn2-ami-hvm-*-x86_64-gp2"]
    }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
}

/*output "aws_ami_id" {
    values = "data.aws_ami.latest-amazon-linux-image.id"
}*/

resource "aws_key_pair" "ssh-key" {
    key_name = "server-ssh-key"
    public_key = "${file(var.public_key_location)}"  
}

resource "aws_instance" "myapp-server" {
    ami = data.aws_ami.latest-amazon-linux-image.id
    instance_type= var.instance_type

    subnet_id = aws_subnet.mk-app-subnet.id
    vpc_security_group_ids = [aws_security_group.my-app-sg.id]
    availability_zone = var.availability_zone

    associate_public_ip_address = true
   # key_name = "aws_key_pair.ssh-key.key_name"

    user_data = file("entry-script.sh")
    tags = {
        name = "${var.env_prefix}-server"
    } 
}