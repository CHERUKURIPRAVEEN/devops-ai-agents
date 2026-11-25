output "instance_id" {
  value = one(module.devops_ai_ec2.instance_ids)
}
output "instance_name" {
  value = one(module.devops_ai_ec2.instance_names)
}
output "private_ip" {
  value = one(module.devops_ai_ec2.private_ips)
}
output "public_ip" {
  value = one(module.devops_ai_ec2.public_ips)
}
output "nat_gateway_id" {
  value = aws_nat_gateway.this.id
}
output "nat_public_ip" {
  value = aws_eip.nat.public_ip
}
