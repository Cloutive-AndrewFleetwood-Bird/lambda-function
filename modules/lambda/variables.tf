variable "environment" {
  description = "Environment name"
  type        = string
}

variable "lambda_functions" {
  description = "Map of Lambda functions to deploy"
  type = map(object({
    handler     = string
    path        = string
    route       = string
    http_method = optional(string, "POST")
  }))
}

variable "lambda_timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 10
}

variable "lambda_memory" {
  description = "Lambda function memory in MB"
  type        = number
  default     = 256
}

variable "vpc_subnet_ids" {
  description = "VPC subnet IDs for Lambda"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID for Lambda"
  type        = string
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}
