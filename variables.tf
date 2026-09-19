variable "lambda_functions" {
  description = "Map of Lambda functions to deploy"
  type = map(object({
    handler = string
    path    = string
    route   = string
  }))
  default = {
    "character-counter-service" = {
      handler = "lambda_function.lambda_handler"
      path    = "char_counter"
      route   = "/count"
    }
    "json-validator-service" = {
      handler = "lambda_function.lambda_handler"
      path    = "json_validator"
      route   = "/validate"
    }
  }
}

variable "allowed_cidr" {
  description = "CIDR block allowed to access the ALB"
  type        = string
  default     = "63.176.242.1/32"
}
