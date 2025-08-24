variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)

  
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)

  
}


variable "database_subnet_cidrs" {
  description = "List of CIDR blocks for database subnets"
  type        = list(string)
  
}