variable "environment" {
  description = "Environment name (dev, test, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "Environment must be dev, test, or prod."
  }
}

variable "lambda_functions" {
  description = "Map of Lambda functions to deploy"
  type = map(object({
    handler     = string
    path        = string
    route       = string
    http_method = optional(string, "POST")
  }))
  default = {
    "character-counter-service" = {
      handler     = "lambda_function.lambda_handler"
      path        = "char_counter"
      route       = "/count"
      http_method = "GET"
    }
    "json-validator-service" = {
      handler     = "lambda_function.lambda_handler"
      path        = "json_validator"
      route       = "/validate"
      http_method = "POST"
    }
  }
}

variable "allowed_cidr" {
  description = "CIDR block allowed to access the ALB"
  type        = string
  default     = "0.0.0.0/0"
}

variable "lambda_timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 10
  validation {
    condition     = var.lambda_timeout >= 1 && var.lambda_timeout <= 900
    error_message = "Lambda timeout must be between 1 and 900 seconds."
  }
}

variable "lambda_memory" {
  description = "Lambda function memory in MB"
  type        = number
  default     = 256
  validation {
    condition     = contains([128, 256, 512, 1024, 1536, 2048, 3008], var.lambda_memory)
    error_message = "Lambda memory must be 128, 256, 512, 1024, 1536, 2048, or 3008 MB."
  }
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7
  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.log_retention_days)
    error_message = "Log retention must be a valid CloudWatch retention period."
  }
}

variable "alb_enable_logging" {
  description = "Enable ALB access logging"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    ManagedBy = "terraform"
  }
}

variable "api_gateway_allowed_ips" {
  description = "List of allowed IP addresses/CIDR blocks for API Gateway access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
  validation {
    condition     = length(var.api_gateway_allowed_ips) > 0
    error_message = "At least one allowed IP must be specified"
  }
}

