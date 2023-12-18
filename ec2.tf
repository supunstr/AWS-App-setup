################################################
# EC2 creation via loop with custom user data  #
################################################

resource "aws_key_pair" "this" {
  key_name   = var.ssh_access_key
  public_key = var.public_key
}


resource "aws_instance" "this" {
  count                       = length(var.asp_ec2)
  ami                         = element(values(var.asp_ec2), count.index).ec2_ami
  instance_type               = element(values(var.asp_ec2), count.index).ec2_instance_type
  key_name                    = aws_key_pair.this.key_name
  subnet_id                   = split("-", "${element(values(var.asp_ec2), count.index).ec2_name}")[1] == "1" ? aws_subnet.this[0].id : aws_subnet.this[1].id
  associate_public_ip_address = true
  private_ip                  = element(values(var.asp_ec2), count.index).private_ip
  source_dest_check           = true
  #    iam_instance_profile        = aws_iam_instance_profile.cwagent_profile.name


  vpc_security_group_ids = compact([
    aws_security_group.OfficeRangeSSHSecurityGroup.id,
    element(values(var.asp_ec2), count.index).ec2_name == "API-1" || element(values(var.asp_ec2), count.index).ec2_name == "API-2" ? aws_security_group.SG-API.id : null,
    element(values(var.asp_ec2), count.index).ec2_name == "Admin-1" || element(values(var.asp_ec2), count.index).ec2_name == "Admin-2" ? aws_security_group.SG-ADMIN.id : null,
    # Add other security groups based on conditions...
  ])

  tags = {
    Name = "${var.project}-${element(values(var.asp_ec2), count.index).ec2_name}"
  }

  /*
    user_data = templatefile("./scripts/configure_server.sh", { 
        server_name         = "${each.value.name}", 
        CUST                = "${local.CUST}", 
		DBOLDUSER           = "${local.DBOLDUSER}", 
        DBOLDPWD            = "${local.DBOLDPWD}",
        DBUSER              = "${local.DBUSER}", 
        DBPWD               = "${local.DBPWD}", 
        DBHOST              = "${module.rds_instance.rds_address}",
        CONTROLSERVER       = "${local.CONTROLSERVER}", 
        TUNNELSERVER        = "${local.TUNNELSERVER}", 
        APISERVER           = "${local.APISERVER}", 
        RADIUSSERVER        = "${local.RADIUSSERVER}", 
        PORTALSERVER        = "${local.PORTALSERVER}", 
        NFSSERVER           = "${local.NFSSERVER}", 
        LICENSOR_SERVER_URL = "${local.LICENSOR_SERVER_URL}", 
        JWTTOKEN            = "${local.JWTTOKEN}", 
        SPTOKEN             = "${local.SPTOKEN}"
    })
*/
}

resource "aws_eip" "ASP-ELP" {
    count                       = length(var.asp_ec2)
	instance	= aws_instance.this[count.index].id
	vpc 		= true

  tags = {
    Name = "${var.project}-${element(values(var.asp_ec2), count.index).ec2_name}-EIP"
  }
}


###################
# Security Groups #
###################

resource "aws_security_group" "default_sg" {

  name        = "${var.project}_default_sg"
  description = "default VPC security group"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = []
    self            = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}_default_sg"
  }
}

data "aws_security_group" "default_sg" {
  id = aws_security_group.default_sg.id
}

resource "aws_security_group" "load_balancer_sg" {

  name        = "${var.project}_lb_sg"
  description = "Load balancer security group"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project}_lb_sg"
  }
}

data "aws_security_group" "load_balancer_sg" {
  id = aws_security_group.load_balancer_sg.id
}

resource "aws_security_group" "SG-TA-AUTH" {
  name        = "${var.project}_TA-AUTH_sg"
  description = "Security group for TA-Auth"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port   = 2912
    to_port     = 2913
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.this[0].public_ip}/32"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.this[2].public_ip}/32"]
  }
  egress {
    from_port   = 2912
    to_port     = 2913
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.project}_TA-AUTH_sg"
  }
}

data "aws_security_group" "SG-TA-AUTH" {
  id = aws_security_group.SG-TA-AUTH.id
}

resource "aws_security_group" "SG-CONTROL" {
  name        = "${var.project}_CONTROL_sg"
  description = "Security group for CONTROL"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.project}_CONTROL_sg"
  }
}

data "aws_security_group" "SG-CONTROL" {
  id = aws_security_group.SG-CONTROL.id
}

resource "aws_security_group" "SG-TA" {
  name        = "${var.project}_TA_sg"
  description = "Security group for TA"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }
  ingress {
    from_port   = 2812
    to_port     = 2813
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.project}_TA_sg"
  }
}

data "aws_security_group" "SG-TA" {
  id = aws_security_group.SG-TA.id
}

resource "aws_security_group" "OfficeRangeSSHSecurityGroup" {

  name        = "${var.project}_OfficeRangeSSHSecurityGroup"
  description = "Allow SSH access from the Office Ranges"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port   = 161
    to_port     = 161
    protocol    = "udp"
    cidr_blocks = ["128.199.71.219/32"]
  }
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["128.199.71.219/32"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["116.12.209.224/28", "203.118.42.235/32", "203.118.42.30/32", "112.199.189.4/32"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.project}_OfficeRangeSSHSecurityGroup"
  }
}

data "aws_security_group" "OfficeRangeSSHSecurityGroup" {
  id = aws_security_group.OfficeRangeSSHSecurityGroup.id
}

resource "aws_security_group" "SG-ADMIN" {
  name        = "${var.project}_ADMIN_sg"
  description = "Security group for ADMIN"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.project}_ADMIN_sg"
  }
}

data "aws_security_group" "SG-ADMIN" {
  id = aws_security_group.SG-ADMIN.id
}

resource "aws_security_group" "SG-PORTAL" {
  name        = "${var.project}_PORTAL_sg"
  description = "Security group for PORTAL"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.project}_PORTAL_sg"
  }
}

data "aws_security_group" "SG-PORTAL" {
  id = aws_security_group.SG-PORTAL.id
}

resource "aws_security_group" "SG-NFS" {
  name        = "${var.project}_NFS_sg"
  description = "Security group for NFS"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }
  ingress {
    from_port   = 7789
    to_port     = 7789
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }
  ingress {
    from_port   = 7789
    to_port     = 7789
    protocol    = "udp"
    cidr_blocks = [var.vpc_cidr]
  }
  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.project}_NFS_sg"
  }
}

data "aws_security_group" "SG-NFS" {
  id = aws_security_group.SG-NFS.id
}

resource "aws_security_group" "SG-API" {
  name        = "${var.project}_API_sg"
  description = "Security group for API"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }
  ingress {
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.project}_API_sg"
  }
}

data "aws_security_group" "SG-API" {
  id = aws_security_group.SG-API.id
}


resource "aws_security_group" "SG-DB" {
  name        = "${var.project}_DB_sg"
  description = "Security group for DB"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.project}_DB_sg"
  }
}

data "aws_security_group" "SG-DB" {
  id = aws_security_group.SG-DB.id
}


resource "aws_security_group" "SG-TUNNEL" {
  name        = "${var.project}_TUNNEL_sg"
  description = "Security group for TUNNEL"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port   = 10000
    to_port     = 50000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 9443
    to_port     = 9443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.project}_TUNNEL_sg"
  }
}

data "aws_security_group" "SG-TUNNEL" {
  id = aws_security_group.SG-TUNNEL.id
}
