provider "aws" {
    region= "eu-west-3"
}

resource "aws_vpc" "mk-app-vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name: "${var.env_prefix}-vpc"
    }
}

#module "myapp-subnet" {
#    source = "./module/subnet"
#    subnet_cidr_block = "var.subnet_cidr_block"
#    availability_zone = "var.availability_zone"
#    env_prefix = "var.env_prefix"
#    vpc_id = "vpc-5b3a0d32"
#    route_table_id = "rtb-f6989c9f"

#}

resource "aws_security_group" "my-app-sg" {
    name = "var.aws_security_group.id"
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

resource "aws_key_pair" "ssh-key" {
    key_name = "server-ssh-key"
    public_key = "${file(var.public_key_location)}"  
}

resource "aws_instance" "myapp-server" {
    ami = data.aws_ami.latest-amazon-linux-image.id
    instance_type= var.instance_type

    subnet_id = "subnet-ce833d83"
    security_groups = ["sg-3cbb0756"]
    availability_zone = var.availability_zone

    associate_public_ip_address = true
   # key_name = "aws_key_pair.ssh-key.key_name"

    user_data = file("entry-script.sh")
   
#    connection {
#        type = "ssh"
#        host = self.public_ip
#        user = "ec2-user"
#        private_key = file(var.private_key_location)
     
#   }
#   provisioner "file" {
#       source = "entry-script.sh"
#        destination = "/home/ec2-user/entry-script.sh"
      
#    }

#    provisioner "remote-exec" {
#       script = file("entry-script.sh")
     
#   }
#   provisioner "local-exec" {
#       command = "echo ${self.public_ip}"
     
#   }
#    provisioner "remote-exec" {
#        inline = [
#            "export ENV=dev",
#            "mkdir newdir",
#            "sudo yum install mysql",
#            "sudo yum install vim" 
#        ]
      
#    }

    tags = {
        name = "${var.env_prefix}-server"
    } 
}