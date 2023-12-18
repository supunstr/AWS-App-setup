aws_region = "us-east-1"
vpc_cidr   = "192.168.0.0/16"
vpc_name   = "testvpc"
project    = "test-project"
environment = "production"


subnets = {
  subnet01 = {
    subnet_cidr_block        = "192.168.1.0/24"
    subnet_availability_zone = "us-east-1a"
    subnet_name              = "subnet-01"

  },
  subnet02 = {
    subnet_cidr_block        = "192.168.2.0/24"
    subnet_availability_zone = "us-east-1b"
    subnet_name              = "subnet-02"

  }
}

ssh_access_key = "asp-ssh-access"
public_key     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC7d+XHMVRuTo8uVr81M5uFlLqbCt+k3gHtZ0JJrInJR8l0S0qD7FACFUrI1UyDyIgmIa3rMPHqAZ6hf1iWaF5Eki248PPutjdtB13yxVXUe2iUTVoXZc7zh48NdcLtlrtSDNpYOFbV2oUftRgs9ldJzMBb5xSvfNkmEk5GAewU11IT3512dPiIPqXOSEI71FS3GgCBpdXulEbou7brdAnXJ3Zpr4ji1RrQCsX5glR8aCJG6A1UGXGGXxZcqcvfyjVfBh8U8UTSWJTmYzEi95Z//af9/aPPryTMumLyM+xT8c/pKs7aD7xjfkQhXHEgjBtVVWB+ZOi0g6GGUOzQN/InjbLPllS8slVcjzyeO/Yx+NU6onC7OFDoApuQ+OtJUXRBBoOSChdfOISdVUzFj6a6gdWqLi4tN3W9PWKJgaIlgzV9CRlHlIuCkO1wMqVxNaMoZS32GWvHpFi+z6HCgec3oGtZCCiOUkWOZzF4X/5mWSHvJHmlZxdpaVvWy6y3o+U="

asp_ec2 = {
  Admin-1 = {
    ec2_ami           = "ami-0dbc3d7bc646e8516"
    ec2_instance_type = "t2.micro"
    private_ip        = "192.168.1.10"
    ec2_name          = "Admin-1"

  },
  Admin-2 = {
    ec2_ami           = "ami-0dbc3d7bc646e8516"
    ec2_instance_type = "t2.micro"
    private_ip        = "192.168.2.10"
    ec2_name          = "Admin-2"

  },
  API-1 = {
    ec2_ami           = "ami-0dbc3d7bc646e8516"
    ec2_instance_type = "t2.micro"
    private_ip        = "192.168.1.11"
    ec2_name          = "API-1"

  },
  API-2 = {
    ec2_ami           = "ami-0dbc3d7bc646e8516"
    ec2_instance_type = "t2.micro"
    private_ip        = "192.168.2.12"
    ec2_name          = "API-2"

  }
}

####################### ALB #########################
