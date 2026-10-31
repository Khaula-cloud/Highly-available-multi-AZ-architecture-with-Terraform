#!/bin/bash
# Force an RDS Multi-AZ failover (reboot with failover).
# Usage: ./scripts/failover_test.sh <db-identifier> [region]
set -euo pipefail
DB="${1:?db identifier required}"
REGION="${2:-us-east-1}"
aws rds reboot-db-instance --region "$REGION" --db-instance-identifier "$DB" --force-failover
echo "Failover started. Watch events:"
echo "aws rds describe-events --region $REGION --source-identifier $DB --source-type db-instance --duration 30"
