# Cinfra Lambda Services

Two serverless AWS Lambda functions for the development team.

## Services

- **Character Counter** (`character-counter-service`) — Counts characters in a string
  - Input: Query parameter `string` or request body
  - Output: JSON with character count
- **JSON Validator** (`json-validator-service`) — Validates JSON strings
  - Input: JSON string in request body
  - Output: JSON validation result

## Deployment

### Prerequisites

- AWS account with CLI credentials configured
- Terraform installed

### Deploy

```bash
export AWS_PROFILE=personal
terraform init
terraform plan
terraform apply
```



### Outputs

Terraform will output the Lambda function URLs:

```
character_counter_url = "https://<url-id>.lambda-url.eu-central-1.on.aws/"
json_validator_url = "https://<url-id>.lambda-url.eu-central-1.on.aws/"
```



## Usage Examples



### Character Counter

```bash
curl "https://<url>/character-counter-service?string=hello%20world"
# Output: {"input_string": "hello world", "character_count": 11}
```



### JSON Validator

```bash
curl -X POST "https://<url>/json-validator-service" \
  -H "Content-Type: application/json" \
  -d '{"test": "data"}'
# Output: {"valid": true, "message": "Valid JSON string"}
```



## Infrastructure

- **VPC** with public subnets across 2 availability zones
- **Application Load Balancer** (ALB) with path-based routing
- **Lambda functions** (private, no public URLs)
- **Security Group** with restricted ingress (configurable by CIDR)
- **Target Groups** for Lambda routing
- **S3 remote state** storage with versioning and encryption
- **DynamoDB** state locking for team collaboration
- **Parameter Store** with ALB endpoint

## Configuration

To restrict ALB access to a specific IP/CIDR, set the `allowed_cidr` variable:

```bash
terraform apply -var="allowed_cidr=YOUR_IP/32"
```

Example for a single IP:
```bash
terraform apply -var="allowed_cidr=203.0.113.42/32"
```

