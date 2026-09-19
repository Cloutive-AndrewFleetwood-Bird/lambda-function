variable "cloutive_personal_account_id" {
  description = "AWS Account ID for cloutive-personal (to prevent accidental deployment to wrong account)"
  type        = string
  validation {
    condition     = can(regex("^[0-9]{12}$", var.cloutive_personal_account_id))
    error_message = "Account ID must be a 12-digit number"
  }
}
