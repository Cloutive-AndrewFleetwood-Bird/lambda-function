module "networking" {
  source = "./modules/networking"

  environment = var.environment
  vpc_cidr    = "10.0.0.0/16"
  tags        = var.tags
}

module "lambda" {
  source = "./modules/lambda"

  environment       = var.environment
  lambda_functions  = var.lambda_functions
  lambda_timeout    = var.lambda_timeout
  lambda_memory     = var.lambda_memory
  vpc_subnet_ids    = module.networking.private_subnet_ids
  security_group_id = module.networking.lambda_security_group_id
  tags              = var.tags

  depends_on = [module.networking]
}

module "alb" {
  source = "./modules/alb"

  environment       = var.environment
  vpc_id            = module.networking.vpc_id
  subnet_ids        = module.networking.public_subnet_ids
  security_group_id = module.networking.alb_security_group_id
  lambda_functions  = module.lambda.function_details
  allowed_cidr      = var.allowed_cidr
  alb_enable_logging = var.alb_enable_logging
  tags              = var.tags

  depends_on = [module.lambda]
}

module "api_gateway" {
  source = "./modules/api_gateway"

  environment             = var.environment
  lambda_functions        = module.lambda.function_details
  invoke_arns             = module.lambda.invoke_arns
  api_gateway_allowed_ips = var.api_gateway_allowed_ips
  log_retention_days      = var.log_retention_days
  tags                    = var.tags

  depends_on = [module.lambda]
}

module "monitoring" {
  source = "./modules/monitoring"

  environment              = var.environment
  alb_name                 = module.alb.alb_name
  api_gateway_name         = module.api_gateway.api_name
  lambda_function_names    = module.lambda.all_function_names
  log_retention_days       = var.log_retention_days
  tags                     = var.tags

  depends_on = [module.alb, module.api_gateway]
}
