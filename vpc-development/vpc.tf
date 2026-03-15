resource "aws_vpc" "main" {
    cidr_block       = var.cidr
    instance_tenancy = "default"
    enable_dns_hostnames = true
    tags =  merge(
        var.vpc_tags,
        local.common_tags,
        {
            Name = local.common_name_suffix
        }
  )
}

# creation of internet gateway and attach vpc

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.main.id

    tags = merge(
        var.igw_tags,
        local.common_tags,
    {
        Name = local.common_name_suffix
    }
  )
}

# creation of 2 public subnet in different AZs with cidr in us-east1a and 1b region

resource "aws_subnet" "public" {
    count = length(var.public_subnet_cidrs)
    vpc_id     = aws_vpc.main.id
    cidr_block = var.public_subnet_cidrs[count.index]
    availability_zone = local.az_names[count.index]
    map_public_ip_on_launch = true
    tags = merge(
        var.public_subnet_tags,
        local.common_tags,
    {
        Name = "${local.common_name_suffix}-public-${local.az_names[count.index]}" # roboshop-dev-public-us-east-1a
    }
  )
}

# creation of 2 private subnet in different AZs with cidr in us-east1a and 1b region

resource "aws_subnet" "private" {
    count = length(var.private_subnet_cidrs)
    vpc_id     = aws_vpc.main.id
    cidr_block = var.private_subnet_cidrs[count.index]
    availability_zone = local.az_names[count.index]
    tags = merge(
        var.private_subnet_tags,
        local.common_tags,
    {
        Name = "${local.common_name_suffix}-private-${local.az_names[count.index]}" # roboshop-dev-private-us-east-1a
    }
  )
}

# creation of 2 database subnet in different AZs with cidr in us-east1a and 1b region

resource "aws_subnet" "database" {
    count = length(var.database_subnet_cidrs)
    vpc_id     = aws_vpc.main.id
    cidr_block = var.database_subnet_cidrs[count.index]
    availability_zone = local.az_names[count.index]
    tags = merge(
        var.database_subnet_tags,
        local.common_tags,
    {
        Name = "${local.common_name_suffix}-database-${local.az_names[count.index]}" # roboshop-dev-database-us-east-1a
    }
  )
}

# creation of public route table 

resource "aws_route_table" "public_route_table" {
    vpc_id = aws_vpc.main.id
    tags =  merge(
        var.public_route_table_tags,
        local.common_tags,
    {
        Name = "${local.common_name_suffix}-public-route-table" # roboshop-dev-public-route-table
    }
  )
}

# creation of private route table 

resource "aws_route_table" "private_route_table" {
    vpc_id = aws_vpc.main.id
    tags =  merge(
        var.private_route_table_tags,
        local.common_tags,
    {
        Name = "${local.common_name_suffix}-private-route-table" # roboshop-dev-private-route-table
    }
  )
}

# creation of database route table 

resource "aws_route_table" "database_route_table" {
    vpc_id = aws_vpc.main.id
    tags =  merge(
        var.database_route_table_tags,
        local.common_tags,
    {
        Name = "${local.common_name_suffix}-database-route-table" # roboshop-dev-database-route-table
    }
  )
}

# creation of route in public route table to allow internet access

resource "aws_route" "public" {
    route_table_id = aws_route_table.public_route_table.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
}

#creation of elastic ip

resource "aws_eip" "nat" {
    domain   = "vpc"
    tags =  merge(
        var.eip_tags,
        local.common_tags,
        {
        Name = "${local.common_name_suffix}-nat" # roboshop-dev-nat-eip
        }
    )
}

# creation of nat gateway in public subnet and associate elastic ip to it

resource "aws_nat_gateway" "nat" {
    allocation_id = aws_eip.nat.id
    subnet_id = aws_subnet.public[0].id
    tags =  merge(
        var.nat_gateway_tags,
        local.common_tags,
        {
        Name = "${local.common_name_suffix}-nat-gateway" # roboshop-dev-nat-gateway
        }
    )

    # To ensure proper ordering, it is recommended to add an explicit dependency
    # on the Internet Gateway for the VPC.
    depends_on = [aws_internet_gateway.igw]
}

# creation of route in private route table to allow internet access

resource "aws_route" "private" {
    route_table_id = aws_route_table.private_route_table.id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id  = aws_nat_gateway.nat.id
}


# creation of route in database route table to allow internet access

resource "aws_route" "database" {
    route_table_id = aws_route_table.database_route_table.id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id  = aws_nat_gateway.nat.id
}

# association of public subnet with public route table

resource "aws_route_table_association" "public" {
    count = length(var.public_subnet_cidrs)
    subnet_id = aws_subnet.public[count.index].id
    route_table_id = aws_route_table.public_route_table.id
}

# association of private subnet with private route table

resource "aws_route_table_association" "private" {
    count = length(var.private_subnet_cidrs)
    subnet_id = aws_subnet.private[count.index].id
    route_table_id = aws_route_table.private_route_table.id
}

# association of database subnet with database route table

resource "aws_route_table_association" "database" {
    count = length(var.database_subnet_cidrs)
    subnet_id = aws_subnet.database[count.index].id
    route_table_id = aws_route_table.database_route_table.id
}