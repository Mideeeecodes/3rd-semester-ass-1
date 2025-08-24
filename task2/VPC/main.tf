##create a vpc


##data availablity zone
data "aws_availability_zones" "available" {}



resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
    enable_dns_hostnames = true

    tags = {
        Name = "my_vpc"
    }
}

##create an internet gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

    tags = {
        Name = "my_igw"
    }
}

##create a public subnet
resource "aws_subnet" "my_public_subnet" {
    count = length(var.public_subnet_cidrs)
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
    availability_zone = data.aws_availability_zones.available.names[count.index]
    
        tags = {
            Name = "my_public_subnet"
        }
}


##create a private subnet
resource "aws_subnet" "my_private_subnet" {
    count = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = var.private_subnet_cidrs[count.index]
    map_public_ip_on_launch = false
    availability_zone = data.aws_availability_zones.available.names[count.index]

    
        tags = {
            Name = "my_private_subnet"
        }
}

##public route table
resource "aws_route_table" "my_public_rt" {
  vpc_id = aws_vpc.my_vpc.id

  route {
  cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
    }
    
        tags = {
            Name = "my_public_rt"
        }
}


##associate public subnet with route table
resource "aws_route_table_association" "public_rt_assoc" {
    count = length(var.public_subnet_cidrs)
  subnet_id = aws_subnet.my_public_subnet[count.index].id
  route_table_id = aws_route_table.my_public_rt.id
}  


##eip
resource "aws_eip" "nat_eip" {
  count = length(var.private_subnet_cidrs)
  tags = {
    Name = "my_eip"
  }
}

##nat gateway
resource "aws_nat_gateway" "my_nat_gw" {
  count = length(var.private_subnet_cidrs)
  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id = aws_subnet.my_public_subnet[count.index].id
    tags = {
      Name = "my_nat_gw"
    }
    depends_on = [aws_internet_gateway.my_igw] 
  }


##private route table
resource "aws_route_table" "my_private_rt" {
  vpc_id = aws_vpc.my_vpc.id
    count = length(var.private_subnet_cidrs)
    tags = {
      Name = "my_private_rt"
    }
}
    

# ##create a subnet rds 
# resource "aws_route" "database_subnet" {
#   count = length(var.database_subnet_cidrs)
#   route_table_id = aws_route_table.my_private_rt[count.index].id
#   destination_cidr_block = var.database_subnet_cidrs[count.index]
#   # Optionally, add a gateway_id or nat_gateway_id if needed for the route

#   # Remove vpc_id, availability_zone, and tags as they are not valid for aws_route
# }

##create a subnet for a database
resource "aws_subnet" "my_database_subnet" {
    count = length(var.database_subnet_cidrs)
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = var.database_subnet_cidrs[count.index]
    map_public_ip_on_launch = false
    availability_zone = data.aws_availability_zones.available.names[count.index]

    
        tags = {
            Name = "my_database_subnet"
        }
}  


#create a routetable for data base subnet

resource "aws_route_table" "my_database_rt" {
  vpc_id = aws_vpc.my_vpc.id
    count = length(var.database_subnet_cidrs)
    tags = {
      Name = "my_database_rt"
    }
}