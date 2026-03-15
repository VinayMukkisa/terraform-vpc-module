# This file contains the resources related to VPC peering connection and route creation for peering connection access.

resource "aws_vpc_peering_connection" "default" {
    count= var.is_peering_required ? 1 : 0
    peer_vpc_id   = data.aws_vpc.default.id
    vpc_id        = aws_vpc.main.id
    auto_accept   = true
    accepter {
        allow_remote_vpc_dns_resolution = true
    }

    requester {
        allow_remote_vpc_dns_resolution = true
    }
    tags =  merge(
        var.vpc_tags,
        local.common_tags,
        {
        Name = "${local.common_name_suffix}-default" # roboshop-dev-vpc-peering
        }
    )

}

# creation of route in public route table to allow peering connection access

resource "aws_route" "public_peering" {
    count = var.is_peering_required ? 1 : 0
    route_table_id            = aws_route_table.public_route_table.id
    destination_cidr_block    = data.aws_vpc.default.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id
}

# creation of route in private route table to allow peering connection access

resource "aws_route" "private_peering" {
    count = var.is_peering_required ? 1 : 0
    route_table_id            = aws_route_table.private_route_table.id
    destination_cidr_block    = data.aws_vpc.default.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id
}

# creation of route in main route table to allow peering connection access

resource "aws_route" "default_peering" {
    count = var.is_peering_required ? 1 : 0
    route_table_id            = data.aws_route_table.main.id
    destination_cidr_block    = var.cidr
    vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id
}