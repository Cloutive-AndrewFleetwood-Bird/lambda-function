variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "Public subnet IDs for ALB"
  type        = list(string)
}

variable "security_group_id" {
  description = "ALB security group ID"
  type        = string
}

variable "lambda_functions" {
  description = "Lambda function details"
  type = map(object({
    arn    = string
    name   = string
    route  = string
    method = string
  }))
}

variable "allowed_cidr" {
  description = "CIDR block allowed to access ALB"
  type        = string
  default     = "0.0.0.0/0"
}

variable "alb_enable_logging" {
  description = "Enable ALB access logging"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
