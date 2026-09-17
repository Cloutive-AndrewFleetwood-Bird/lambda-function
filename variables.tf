variable "domain_name" {
  description = "The base domain name (e.g., example.com)"
  type        = string
}

variable "zone_id" {
  description = "The Route53 Hosted Zone ID for the domain"
  type        = string
}
