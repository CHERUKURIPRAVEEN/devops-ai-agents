resource "aws_security_group" "devops_ai" {
  name        = "DEV-A1-DAI-SG"
  description = "DevOps AI outbound only; administration via SSM"
  vpc_id      = local.vpc_id
  tags        = merge(local.tags, { Name = "DEV-A1-DAI-SG" })
  # Also orders EC2 creation after NAT routing through the module's SG input.
  depends_on = [aws_route.private_internet]
}
resource "aws_vpc_security_group_egress_rule" "web" {
  for_each          = toset(["80", "443"])
  security_group_id = aws_security_group.devops_ai.id
  ip_protocol       = "tcp"
  from_port         = tonumber(each.value)
  to_port           = tonumber(each.value)
  cidr_ipv4         = "0.0.0.0/0"
  description       = "Outbound web for packages, models and AWS APIs"
}
