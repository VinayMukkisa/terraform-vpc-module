module "vpc"{
    source="git::https://github.com/VinayMukkisa/terraform-vpc-development.git?ref=main"
    # cidr = "10.0.0.0/16"
    # project_name = "roboshop"
    # environment = "dev"
    cidr =var.vpc_cidr
    project_name = var.project_name
    environment = var.environment
    vpc_tags = var.vpc_tags
    #public subnet
    public_subnet_cidrs =var.public_subnet_cidrs
    #private subnet
    private_subnet_cidrs =var.private_subnet_cidrs
    #database subnet
    database_subnet_cidrs =var.database_subnet_cidrs
    is_peering_required = true
}


