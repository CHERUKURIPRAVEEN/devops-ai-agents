# DevOps AI EC2 consumer configuration
Uses aws-ec2-module v0.20.0, existing Management VPC/subnets/route tables and existing SSM profile. Creates one EIP, public NAT gateway, standalone private default route, security group, two outbound rules and EC2. No new IAM role, VPC or subnet. Local Terraform state; protect and back it up. Commit the generated provider lock file, never state or plan files.

## Before apply
Use Git Bash with the intended personal AWS account and no unexpected AWS credential environment overrides. Run `bash preflight.sh`. Verify identity, EC2-only trust allowing sts:AssumeRole, profile role name, only AmazonSSMManagedInstanceCore attached, no inline policies, and any permissions boundary allows SSM. Existing caller must have EC2 create/read/delete and iam:PassRole for this specific role. Check route tables: private must have no existing default route before first apply; public must have active IGW default route. Review every association and other workloads affected; if existing network is Terraform-managed elsewhere, coordinate route ownership and avoid competing inline route definitions. Check subnet NACLs permit web and return traffic, VPC DNS works, and EC2 instance type offering is present (offering is not capacity guarantee). NAT charges start on creation, continue when EC2 stops. Do not proceed if any checks fail.

Copy terraform.tfvars.example to terraform.tfvars; enter account and actual module-compatible owner emails (do not invent ownership), and set approval true after review. The module requires @veen.com; if you lack suitable addresses, revise upstream validation in a new release rather than falsifying tags.

```
terraform init
terraform fmt -recursive
terraform validate
terraform plan -out=devops.tfplan
terraform show devops.tfplan
terraform apply devops.tfplan
```
Expect only new resources plus the new route, no replacement/deletion of existing resources. Verify selected subnet, absent public IP, IMDSv2, encrypted gp3 100 GiB and no ingress. The upstream module has an embedded provider; use the same CLI credentials as root, no module depends_on. The SG input creates ordering through egress rules and NAT route. Root volume is deleted at termination; backup before destroy. AutoStop/backup tags do not implement automation. Single AZ, not HA.

```
INSTANCE_ID=$(terraform output -raw instance_id)
aws ec2 wait instance-status-ok --instance-ids "$INSTANCE_ID"
aws ssm describe-instance-information --filters "Key=InstanceIds,Values=$INSTANCE_ID"
aws ssm start-session --target "$INSTANCE_ID"
```
Wait for PingStatus Online. Once connected: `cat /etc/os-release`, `free -h`, `df -h /`, `curl -I https://github.com`, and `cloud-init status --wait`. Application/Ansible deployment is a separate phase. Dashboard port forwarding only after the service is installed:
```
aws ssm start-session --target "$INSTANCE_ID" --document-name AWS-StartPortForwardingSession --parameters '{"portNumber":["8501"],"localPortNumber":["8501"]}'
```
Stop EC2 when idle, but EBS and NAT continue billing. Destroy only after reviewing a destroy plan and backing up data; removal of route affects the entire associated subnet. No live Terraform validation performed in authoring environment.
