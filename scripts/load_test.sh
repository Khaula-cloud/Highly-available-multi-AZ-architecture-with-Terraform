#!/bin/bash
# Generate CPU load on ASG instances via SSM to trigger scale-out.
# Usage: ./scripts/load_test.sh <asg-name> [region] [duration-seconds]
set -euo pipefail
ASG="${1:?asg name required}"
REGION="${2:-us-east-1}"
DURATION="${3:-600}"

IDS=$(aws autoscaling describe-auto-scaling-groups --region "$REGION" \
  --auto-scaling-group-names "$ASG" \
  --query "AutoScalingGroups[0].Instances[].InstanceId" --output text)

echo "Stressing: $IDS for ${DURATION}s"
aws ssm send-command --region "$REGION" \
  --document-name "AWS-RunShellScript" \
  --instance-ids $IDS \
  --parameters "commands=[\"stress-ng --cpu 0 --timeout ${DURATION}s\"]" \
  --query "Command.CommandId" --output text

echo "Watch scaling:"
echo "aws autoscaling describe-scaling-activities --region $REGION --auto-scaling-group-name $ASG --max-items 5"
