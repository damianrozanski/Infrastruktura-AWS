#AUTENTYKACJA
provider "aws" {
  region     = "eu-central-1"
}

#VPC
resource "aws_vpc" "vpc" {
  cidr_block       = var.vpc_cidr #wskazanie za pomocą zmiennej zasięgu adresów IP dla naszej sieci
  instance_tenancy = "default"    #serwery będą uzywać współdzielonego hardware'u - opcja darmowa
}

#PODSIECI
resource "aws_subnet" "subnet_first" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.subnet_first_cidr
  availability_zone = "eu-central-1a"
  map_public_ip_on_launch = true #serwery w tej podsieci automatycznie otrzymają publiczny adres IP
}

resource "aws_subnet" "subnet_second" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.subnet_second_cidr
  availability_zone = "eu-central-1b"
  map_public_ip_on_launch = true
}

#BRAMA INTERNETOWA
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}

#TABELA ROUTINGU
resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0" #przekazywanie calego ruchu do bramy internetowej (IPv4) 
    gateway_id = aws_internet_gateway.igw.id
  }

  route {
    ipv6_cidr_block = "::/0" #przekazywanie calego ruchu do bramy internetowej (IPv6) 
    gateway_id      = aws_internet_gateway.igw.id
  }
}

#POŁĄCZENIA TABELI Z PODSIECIAMI
resource "aws_route_table_association" "RTA-first" {
  subnet_id      = aws_subnet.subnet_first.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_route_table_association" "RTA-second" {
  subnet_id      = aws_subnet.subnet_second.id
  route_table_id = aws_route_table.route_table.id
}

#GRUPY BEZPIECZENSTWA
resource "aws_security_group" "security_group" {
  name        = "security_group"
  description = "Otwarcie portow 22 (SSH), 80 (HTTP), 443 (HTTPS)"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "security_group_lb" {
  name        = "security_group_lb"
  description = "Otwarcie portow load balancera"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

#SERWERY
resource "aws_instance" "serwer1" {
  ami                    = "ami-015c25ad8763b2f11" #ID obrazu na ktorym zbudowany zostanie serwer
  instance_type          = "t2.micro"              #typ serwera 
  key_name               = "InzOpr"
  subnet_id              = aws_subnet.subnet_first.id
  vpc_security_group_ids = [aws_security_group.security_group.id]

  #skrypt uruchuchamiany przy inicjalizacji serwera
  user_data = <<-EOF
                 #!/bin/bash
                 sudo apt update -y
                 sudo apt install apache2 -y
                 sudo systemctl start apache2
                 EOF
}

resource "aws_instance" "serwer2" {
  ami                    = "ami-015c25ad8763b2f11" #ID obrazu na ktorym zbudowany zostanie serwer
  instance_type          = "t2.micro"              #typ serwera 
  key_name               = "InzOpr"
  subnet_id              = aws_subnet.subnet_first.id
  vpc_security_group_ids = [aws_security_group.security_group.id]

  #skrypt uruchuchamiany przy inicjalizacji serwera
  user_data = <<-EOF
                 #!/bin/bash
                 sudo apt update -y
                 sudo apt install apache2 -y
                 sudo systemctl start apache2
                 EOF
}

resource "aws_instance" "serwer3" {
  ami                    = "ami-015c25ad8763b2f11" #ID obrazu na ktorym zbudowany zostanie serwer
  instance_type          = "t2.micro"              #typ serwera 
  key_name               = "InzOpr"
  subnet_id              = aws_subnet.subnet_second.id
  vpc_security_group_ids = [aws_security_group.security_group.id]

  #skrypt uruchuchamiany przy inicjalizacji serwera
  user_data = <<-EOF
                 #!/bin/bash
                 sudo apt update -y
                 sudo apt install apache2 -y
                 sudo systemctl start apache2
                 EOF
}

resource "aws_instance" "serwer4" {
  ami                    = "ami-015c25ad8763b2f11" #ID obrazu na ktorym zbudowany zostanie serwer
  instance_type          = "t2.micro"              #typ serwera 
  key_name               = "InzOpr"
  subnet_id              = aws_subnet.subnet_second.id
  vpc_security_group_ids = [aws_security_group.security_group.id]

  #skrypt uruchuchamiany przy inicjalizacji serwera
  user_data = <<-EOF
                 #!/bin/bash
                 sudo apt update -y
                 sudo apt install apache2 -y
                 sudo systemctl start apache2
                 EOF
}

#LOAD BALANCER
resource "aws_lb" "lb" {
  name               = "Load-Balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.security_group_lb.id]
  subnets            = [aws_subnet.subnet_first.id, aws_subnet.subnet_second.id]
}

#TARGET GROUP
resource "aws_lb_target_group" "target_group" {
  name     = "target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id
}

resource "aws_lb_target_group_attachment" "serwer1_att" {
  target_group_arn = aws_lb_target_group.target_group.arn
  target_id        = aws_instance.serwer1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "serwer2_att" {
  target_group_arn = aws_lb_target_group.target_group.arn
  target_id        = aws_instance.serwer2.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "serwer3_att" {
  target_group_arn = aws_lb_target_group.target_group.arn
  target_id        = aws_instance.serwer3.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "serwer4_att" {
  target_group_arn = aws_lb_target_group.target_group.arn
  target_id        = aws_instance.serwer4.id
  port             = 80
}

#LISTENER
resource "aws_lb_listener" "listener-dr" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}
