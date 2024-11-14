# Provider-Konfiguration
provider "aws" {
  region = "eu-central-1"
}

# VPC (Virtual Private Cloud) Definition
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Main-VPC"
  }
}

# Subnetze innerhalb der VPC
resource "aws_subnet" "subnet_1" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-central-1a"
  tags = {
    Name = "Subnet-1"
  }
}

resource "aws_subnet" "subnet_2" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-central-1b"
  tags = {
    Name = "Subnet-2"
  }
}

# Internet Gateway für die VPC
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "Main-Internet-Gateway"
  }
}

# Route Table für die VPC
resource "aws_route_table" "main_route_table" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }
  tags = {
    Name = "Main-Route-Table"
  }
}

# Route Table Zuordnungen für die Subnetze
resource "aws_route_table_association" "subnet_1_association" {
  subnet_id      = aws_subnet.subnet_1.id
  route_table_id = aws_route_table.main_route_table.id
}

resource "aws_route_table_association" "subnet_2_association" {
  subnet_id      = aws_subnet.subnet_2.id
  route_table_id = aws_route_table.main_route_table.id
}

# Mehrere EC2-Instanzen mit individuellen Eigenschaften
resource "aws_instance" "instance_1" {
  ami           = "ami-0eddb4a4e7d846d6f"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.subnet_1.id
  tags = {
    Name = "Github-Actions-Instanz-1"
  }
}

resource "aws_instance" "instance_2" {
  ami           = "ami-0eddb4a4e7d846d6f"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.subnet_2.id
  tags = {
    Name = "Github-Actions-Instanz-2"
  }
}

# S3-Bucket zur Speicherung von Daten
resource "aws_s3_bucket" "data_bucket" {
  bucket = "github-actions-data-bucket"
  acl    = "private"
  tags = {
    Name = "Data-Bucket"
  }
}

# RDS-Datenbankinstanz
resource "aws_db_instance" "main_db" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "5.7.33"
  instance_class       = "db.t3.micro"
  username             = "admin"
  password             = "mypassword123"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.main_db_subnet_group.name
  tags = {
    Name = "Main-RDS-Instance"
  }
}

# Security Group für die RDS-Datenbank
resource "aws_security_group" "db_sg" {
  vpc_id = aws_vpc.main_vpc.id
  ingress {
    from_port   = 3306
    to_port     = 3306
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
    Name = "DB-Security-Group"
  }
}

# Subnet-Group für die RDS-Datenbank
resource "aws_db_subnet_group" "main_db_subnet_group" {
  name       = "main-db-subnet-group"
  subnet_ids = [aws_subnet.subnet_1.id, aws_subnet.subnet_2.id]
  tags = {
    Name = "Main-DB-Subnet-Group"
  }
}
