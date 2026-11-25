#!/usr/bin/env bash
set -euo pipefail
export AWS_PROFILE="${AWS_PROFILE:-default}"
export AWS_DEFAULT_REGION=us-east-1
export AWS_PAGER=""
role=Basic-SSM-Session-Manager-Role
aws sts get-caller-identity
aws iam get-instance-profile --instance-profile-name "$role" --query 'InstanceProfile.Roles[].RoleName'
aws iam get-role --role-name "$role" --query 'Role.{Trust:AssumeRolePolicyDocument,Boundary:PermissionsBoundary}'
aws iam list-attached-role-policies --role-name "$role"
aws iam list-role-policies --role-name "$role"
aws ec2 describe-route-tables --route-table-ids rtb-0a843997590d1d923 rtb-0a069488e5fb491ab
aws ec2 describe-instance-type-offerings --location-type availability-zone --filters Name=location,Values=us-east-1a Name=instance-type,Values=r7i.xlarge
aws ec2 describe-nat-gateways --filter Name=vpc-id,Values=vpc-0ece0375c58175110
