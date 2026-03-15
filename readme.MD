# Terraform AWS VPC Infrastructure

This repository contains a **reusable Terraform module to create a production-ready AWS VPC architecture** with public, private, and database subnets across multiple Availability Zones.

The project follows **Terraform modular architecture best practices** and demonstrates how to create scalable networking infrastructure.

---

# Architecture Diagram

```
                         Internet
                             │
                      Internet Gateway
                             │
               ┌─────────────┴─────────────┐
               │                           │
        Public Subnet (AZ-1a)        Public Subnet (AZ-1b)
               │
           NAT Gateway
               │
      ┌────────┴────────────┐
      │                     │
 Private Subnet (AZ-1a)  Private Subnet (AZ-1b)
      │                     │
Database Subnet (AZ-1a) Database Subnet (AZ-1b)
```

---

# Project Structure

```
terraform-vpc
│
├── vpc-development        # Reusable Terraform module
│   ├── data.tf
│   ├── locals.tf
│   ├── outputs.tf
│   ├── peering.tf
│   ├── variables.tf
│   └── vpc.tf
│
└── vpc-test               # Example environment using module
    ├── main.tf
    ├── provider.tf
    ├── variables.tf
    └── outputs.tf
```

---

# Resources Created

The Terraform module provisions the following AWS resources.

## Core Networking

* VPC
* Internet Gateway (IGW)

## Subnets

* 2 Public Subnets
* 2 Private Subnets
* 2 Database Subnets

## NAT Infrastructure

* Elastic IP
* NAT Gateway (in Public Subnet)

## Route Tables

* Public Route Table
* Private Route Table
* Database Route Table

## Routing

* Internet Gateway route for public subnets
* NAT Gateway route for private subnets
* NAT Gateway route for database subnets

## Route Table Associations

* Public subnets → Public route table
* Private subnets → Private route table
* Database subnets → Database route table

## VPC Peering (Optional)

* Peering between created VPC and Default VPC
* Routes added in both VPCs

---

# Module Inputs

| Variable              | Description                 | Type         |
| --------------------- | --------------------------- | ------------ |
| cidr                  | VPC CIDR block              | string       |
| project_name          | Project name                | string       |
| environment           | Environment name            | string       |
| vpc_tags              | Tags for VPC                | map(string)  |
| public_subnet_cidrs   | Public subnet CIDR blocks   | list(string) |
| private_subnet_cidrs  | Private subnet CIDR blocks  | list(string) |
| database_subnet_cidrs | Database subnet CIDR blocks | list(string) |
| is_peering_required   | Enable VPC peering          | bool         |

---

# Module Outputs

| Output              | Description         |
| ------------------- | ------------------- |
| vpc_id              | Created VPC ID      |
| public_subnet_ids   | Public subnet IDs   |
| private_subnet_ids  | Private subnet IDs  |
| database_subnet_ids | Database subnet IDs |

---

# Example Usage

Example configuration from **vpc-test/main.tf**

```hcl
module "vpc" {

  source = "../vpc-development"

  cidr        = var.vpc_cidr
  project_name = var.project_name
  environment  = var.environment

  vpc_tags = var.vpc_tags

  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
  database_subnet_cidrs = var.database_subnet_cidrs

  is_peering_required = true
}
```

---

# How to Deploy

Initialize Terraform:

```
terraform init
```

Preview infrastructure changes:

```
terraform plan
```

Create infrastructure:

```
terraform apply
```

---

# Requirements

| Tool         | Version |
| ------------ | ------- |
| Terraform    | >= 1.3  |
| AWS Provider | >= 4.0  |

---

# Features

* Multi Availability Zone architecture
* Three-tier subnet design
* Secure database isolation
* NAT gateway for outbound internet access
* Internet access for public subnets
* Optional VPC peering with default VPC
* Modular and reusable Terraform design




