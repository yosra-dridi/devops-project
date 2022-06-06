variable "primary_subnet_cidr" {
    type = string
    description = "subnet cidr which we are going to user primarily"
}

variable "ec2_instance_type" {
    type = string
    description = "free tier t2 instance"
}

variable "amazon_ami" {
    type = string
    description = "virtualization image to use for the instances"
}