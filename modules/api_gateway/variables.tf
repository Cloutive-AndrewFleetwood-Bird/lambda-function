variable "environment" {
  description = "Environment name"
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

variable "invoke_arns" {
  description = "Lambda function invoke ARNs"
  type        = map(string)
}

variable "api_gateway_allowed_ips" {
  description = "List of allowed IP addresses for API Gateway"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
