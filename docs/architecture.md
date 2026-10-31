# Architecture

```
                         Internet
                            |
                    [Internet Gateway]
                            |
              Application Load Balancer (cross-zone)
                     |              |
      ===== VPC 10.0.0.0/16 =========================================
      |  AZ-a                       |  AZ-b                        |
      |  Public 10.0.0.0/24         |  Public 10.0.1.0/24          |
      |   [ALB node] [NAT-a]        |   [ALB node] [NAT-b]         |
      |-----------------------------|------------------------------|
      |  App 10.0.10.0/24           |  App 10.0.11.0/24            |
      |   [EC2] [EC2]  <---- Auto Scaling Group (CPU target 50%) -->|
      |-----------------------------|------------------------------|
      |  DB 10.0.20.0/24            |  DB 10.0.21.0/24             |
      |   [RDS PRIMARY] ==sync replication==> [RDS STANDBY]        |
      ================================================================
```

## Traffic flow
1. User -> ALB (port 80) in public subnets.
2. ALB -> EC2 instances (port 80) in private app subnets, healthy targets only.
3. EC2 -> RDS MySQL (port 3306) in isolated DB subnets.
4. EC2 outbound (patching) -> NAT Gateway in same AZ -> Internet Gateway.

## Failure scenarios
| Failure | Result |
|---|---|
| Instance crashes | ALB health check fails; ASG terminates and replaces it |
| Entire AZ lost | ALB routes to the other AZ; ASG relaunches capacity there; RDS fails over to standby (~60-120s) |
| RDS primary fails | DNS endpoint flips to the standby automatically |
| CPU spike | Target tracking adds instances up to max_size |
| Load drops | ASG scales in down to min_size |

## Security groups
Internet -> alb-sg (80) -> app-sg (80 from alb-sg) -> db-sg (3306 from app-sg)
