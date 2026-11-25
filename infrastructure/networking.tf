resource "aws_eip" "nat" {
  domain     = "vpc"
  tags       = merge(local.tags, { Name = "DEV-A1-DAI-NAT-EIP" })
  depends_on = [terraform_data.guard]
}
resource "aws_nat_gateway" "this" {
  allocation_id     = aws_eip.nat.id
  subnet_id         = local.public_subnet_id
  connectivity_type = "public"
  tags              = merge(local.tags, { Name = "DEV-A1-DAI-NAT" })
}
resource "aws_route" "private_internet" {
  route_table_id         = local.private_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this.id
}
