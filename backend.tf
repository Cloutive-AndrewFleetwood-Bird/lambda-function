terraform {
  backend "s3" {
    bucket         = "cinfra-terraform-state-681526277479"
    key            = "lambda-function/terraform.tfstate"
    region         = "eu-central-1"
    encrypt        = true
  }
}
