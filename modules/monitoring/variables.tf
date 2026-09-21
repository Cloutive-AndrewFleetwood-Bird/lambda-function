variable "environment" {
  description = "Environment name"
  type        = string
}

variable "alb_name" {
  description = "ALB name for monitoring"
  type        = string
}

variable "api_gateway_name" {
  description = "API Gateway name for monitoring"
  type        = string
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7
}

variable "lambda_function_names" {
  description = "Lambda function names"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
