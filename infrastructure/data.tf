locals {
  vpc_id                 = "vpc-0ece0375c58175110"
  private_subnet_id      = "subnet-0d101693d432af5eb"
  public_subnet_id       = "subnet-0c2e005d8bcfc217f"
  private_route_table_id = "rtb-0a843997590d1d923"
  public_route_table_id  = "rtb-0a069488e5fb491ab"
  igw_id                 = "igw-043213a6917eb4a25"
  profile_name           = "Basic-SSM-Session-Manager-Role"
  tags = {
    Project     = "DevOps-AI"
    Environment = "Dev"
    ManagedBy   = "Terraform"
  }
}
data "aws_vpc" "selected" {
  id = local.vpc_id
}
data "aws_subnet" "private" {
  id = local.private_subnet_id
}
data "aws_subnet" "public" {
  id = local.public_subnet_id
}
data "aws_route_table" "private" {
  subnet_id = local.private_subnet_id
}
data "aws_route_table" "public" {
  subnet_id = local.public_subnet_id
}
data "aws_subnets" "module_private" {
  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }
  filter {
    name   = "tag:Name"
    values = [upper("${local.vpc_id}-subnet-PRIVATE-*")]
  }
  filter {
    name   = "availability-zone"
    values = ["us-east-1a"]
  }
}
data "aws_iam_instance_profile" "ssm" {
  name = local.profile_name
}
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "state"
    values = ["available"]
  }
}
resource "terraform_data" "guard" {
  lifecycle {
    precondition {
      condition     = var.approve_shared_route_change
      error_message = "Review shared route-table impact and explicitly approve it in tfvars."
    }
    precondition {
      condition     = data.aws_vpc.selected.tags["Name"] == "MANAGEMENT_VPC" && data.aws_subnet.private.vpc_id == local.vpc_id && data.aws_subnet.public.vpc_id == local.vpc_id
      error_message = "Unexpected VPC or subnet."
    }
    precondition {
      condition     = !data.aws_subnet.private.map_public_ip_on_launch && data.aws_subnet.private.availability_zone == "us-east-1a" && data.aws_subnet.public.availability_zone == "us-east-1a" && toset(data.aws_subnets.module_private.ids) == toset([local.private_subnet_id])
      error_message = "Private subnet must match the module uniquely and disable public IP assignment; both subnets must be in us-east-1a."
    }
    precondition {
      condition     = data.aws_route_table.private.id == local.private_route_table_id && data.aws_route_table.public.id == local.public_route_table_id && anytrue([for r in data.aws_route_table.public.routes : r.cidr_block == "0.0.0.0/0" && r.gateway_id == local.igw_id])
      error_message = "Unexpected route tables or missing public IGW route."
    }
  }
}
