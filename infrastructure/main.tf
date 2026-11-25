module "devops_ai_ec2" {
  source                       = "git::https://github.com/CHERUKURIPRAVEEN/aws-ec2-module.git?ref=v0.20.0"
  region                       = "us-east-1"
  availability_zone            = "us-east-1a"
  required_vpc_name            = "MANAGEMENT_VPC"
  required_private_subnet_name = "PRIVATE"
  required_public_subnet_name  = ""
  ami_id                       = data.aws_ami.ubuntu.id
  application                  = "DEVAI"
  application_code             = "DAI"
  environment                  = "Dev"
  environment_code             = "A1"
  project                      = "DEVAI"
  owner                        = var.owner
  app_owner                    = var.app_owner
  description                  = "DevOps AI Platform Server"
  backup                       = "NonProd"
  instance_type                = "r7i.xlarge"
  number_of_instances          = 1
  instance_role                = data.aws_iam_instance_profile.ssm.name
  key_pair                     = null
  os_disk_size                 = 100
  ebs_optimized                = true
  detailed_monitoring          = true
  user_data_template_name      = "userdata"
  security_groups              = distinct([for rule in aws_vpc_security_group_egress_rule.web : rule.security_group_id])
  tags                         = merge(local.tags, { AutoStop = "true", DeploymentType = "Ansible" })
}
