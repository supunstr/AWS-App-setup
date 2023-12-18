variable "aws_region" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "vpc_name" {
  type = string
}

variable "project" {
  type = string
}

variable "environment"{
  type = string
}

variable "subnets" {
  type = map(object({
    subnet_cidr_block        = string
    subnet_availability_zone = string
    subnet_name              = string
  }))
}

variable "public_key" {
  type = string
}

variable "ssh_access_key" {
  type = string
}

variable "asp_ec2" {
  type = map(object({
    ec2_ami           = string
    ec2_instance_type = string
    #  ec2_key_name      = string
    private_ip = string
    ec2_name   = string
  }))
}