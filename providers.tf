provider "aws" {
  region  = "eu-central-1"
  profile = "cloutive-personal"
}

# Validate we're using the correct account
data "aws_caller_identity" "current" {}

resource "null_resource" "verify_account" {
  lifecycle {
    precondition {
      condition     = data.aws_caller_identity.current.account_id == var.cloutive_personal_account_id
      error_message = "ERROR: Wrong AWS account! Using ${data.aws_caller_identity.current.account_id}, expected ${var.cloutive_personal_account_id} (cloutive-personal)"
    }
  }
}
