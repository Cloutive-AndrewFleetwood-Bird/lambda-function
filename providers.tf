provider "aws" {
  region  = "eu-central-1"
  profile = "cloutive-personal"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
