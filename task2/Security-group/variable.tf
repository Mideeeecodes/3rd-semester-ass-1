##create a load balancer security group
resource "aws_security_group" "my_lb_sg" {
  vpc_id = aws_vpc.my_vpc.id
  name = "my_lb_sg"
  description = "security group for load balancer"
  ingress {
    from_port   = 80
    to_port     = 80
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
        Name = "my_lb_sg"
    }
}

  
    ##create security group for app
resource "aws_security_group" "my_app_sg" {
  vpc_id = aws_vpc.my_vpc.id
  name = "my_app_sg"
  description = "security group for app"
  ingress {
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
        Name = "my_app_sg"
    }
}


##create security group for rds
resource "aws_security_group" "my_rds_sg" {
  vpc_id = aws_vpc.my_vpc.id
  name = "my_rds_sg"
  description = "security group for rds"
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
        Name = "my_rds_sg"
    }
}

##security group rule for app to access rds
resource "aws_security_group_rule" "app_to_rds" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.my_rds_sg.id
  source_security_group_id = aws_security_group.my_app_sg.id
  description              = "Allow app to access rds"
}


##security group rule for lb to access app
resource "aws_security_group_rule" "lb_to_app" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  security_group_id        = aws_security_group.my_app_sg.id
  source_security_group_id = aws_security_group.my_lb_sg.id
  description              = "Allow lb to access app"
}

