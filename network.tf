# _____________________________________VPC_____________________________________
resource "aws_vpc" "vpc" {
  cidr_block           = "${var.cidr_vpc}"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name        = "terraform-wrs-VPC"
    Environment = "${var.environment_tag}"
  }
}
# creo un endpoint per il bucket s3
resource "aws_vpc_endpoint" "s3" {
  vpc_id          = "${aws_vpc.vpc.id}"
  service_name    = "com.amazonaws.eu-west-1.s3"
  route_table_ids = ["${aws_route_table.public_rt.id}"]
}

# _____________________________________GATEWAY_____________________________________
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags = {
    Environment = "${var.environment_tag}"
  }
}

# _____________________________________SUBNETS_____________________________________
resource "aws_subnet" "wrs_public_subnet" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${var.cidr_subnet[0]}"
  map_public_ip_on_launch = "true"
  availability_zone       = "${var.availability_zone[1]}"
  tags = {
    Name        = "terraform-public-subnet"
    Environment = "${var.environment_tag}"
  }
}
resource "aws_subnet" "wrs_private_subnet" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${var.cidr_subnet[1]}"
  map_public_ip_on_launch = "true"
  availability_zone       = "${var.availability_zone[2]}"
  tags = {
    Name        = "terraform-private-subnet"
    Environment = "${var.environment_tag}"
  }
}

# _____________________________________ROUTE TABLE_____________________________________
resource "aws_route_table" "public_rt" {
  vpc_id = "${aws_vpc.vpc.id}"
  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = "${aws_internet_gateway.igw.id}"
  }
  tags = {
    Name        = "terraform-public-rt"
    Environment = "${var.environment_tag}"
  }
}
resource "aws_route_table_association" "as_sub1" {
  subnet_id = "${aws_subnet.wrs_public_subnet1.id}"
  route_table_id = "${aws_route_table.public_rt.id}"
}
resource "aws_route_table_association" "as_sub2" {
  subnet_id = "${aws_subnet.wrs_public_subnet2.id}"
  route_table_id = "${aws_route_table.public_rt.id}"
}

# ___________________________________SECURITY GROUPS___________________________________
resource "aws_security_group" "wrs_sg" {
  name   = "wrs_sg"
  vpc_id = "${aws_vpc.vpc.id}"
  ingress {
      # la porta 80 e' di default per l'SSH
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
      # la porta 22 e' di default per l'SSH
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    # la porta 8080 e' quella di ascolto del server, su cui gira warehouse
    from_port   = 8080
    to_port     = 8080
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
    Name = "terraform-wrs-sg"
    Environment = "${var.environment_tag}"
  }
}

resource "aws_security_group" "rds_sg" {
  name   = "rds_database_sg"
  vpc_id = aws_vpc.vpc.id

  ingress {
    description = "PostgreSQL access"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = ["${aws_security_group.wrs_sg.id}"]
  } 
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "RDS-databse-sg"
    Environment = "${var.environment_tag}"
  }
}

# _____________________________________DNS-DHCP_____________________________________
resource "aws_vpc_dhcp_options" "mydhcp" {
    domain_name = "compute.internal"
    domain_name_servers = ["AmazonProvidedDNS"]
    tags = {
      Name = "terraform-mydhcp"
    }
}

resource "aws_vpc_dhcp_options_association" "dns_resolver" {
    vpc_id = "${aws_vpc.vpc.id}"
    dhcp_options_id = "${aws_vpc_dhcp_options.mydhcp.id}"
}
