# Highly Available Multi-AZ Elastic Cloud Architecture

Terraform project that deploys a fault-tolerant, auto-scaling web tier with a
Multi-AZ managed database on AWS.

## Components
- VPC across 2 AZs: public, private-app and private-db subnets
- Internet Gateway + one NAT Gateway per AZ
- Application Load Balancer with health checks
- Auto Scaling Group (Launch Template, Amazon Linux 2023), CPU target tracking
- RDS MySQL 8.0, Multi-AZ, encrypted, Secrets Manager-managed password
- CloudWatch alarms, SSM Session Manager (no SSH)

## Prerequisites
- Terraform >= 1.5
- AWS CLI configured (`aws configure`) with permissions for VPC, EC2, ELB, RDS, IAM, CloudWatch, Secrets Manager

## Deploy
```bash
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply
```
RDS Multi-AZ takes ~10-15 minutes. When finished, open the `alb_dns_name` output.

## Test
```bash
# 1. Load balancing across AZs: refresh the URL, instance/AZ changes
# 2. Auto scaling
./scripts/load_test.sh $(terraform output -raw asg_name) us-east-1 600
# 3. Database failover
./scripts/failover_test.sh ha-multiaz-mysql us-east-1
# 4. Instance failure: terminate an instance in the console; ASG replaces it
```

## Clean up (avoid charges!)
```bash
terraform destroy
```

## Cost note
NAT Gateways, ALB and Multi-AZ RDS are billed hourly and are NOT free-tier.
Destroy the stack when you finish testing.
