variable "trusted_ingress_ipv4_cidrs" {
  description = "Trusted IPv4 CIDRs allowed to reach workload HTTPS and SSH ports. Empty disables these explicit NSG allow rules."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for cidr in var.trusted_ingress_ipv4_cidrs :
      can(cidrnetmask(cidr)) && try(tonumber(split("/", cidr)[1]) > 0, false)
    ])
    error_message = "trusted_ingress_ipv4_cidrs must contain IPv4 CIDRs with a prefix length greater than zero."
  }
}

variable "shared_data_public_network_access_enabled" {
  description = "Enable the shared storage and Key Vault public endpoints, restricted by deny-by-default ACLs. Requires approved IP access or private connectivity for data-plane operations."
  type        = bool
  default     = false
}

variable "shared_data_allowed_ipv4_cidrs" {
  description = "Approved public IPv4 addresses or CIDRs for shared storage and Key Vault. Empty allows no explicit public clients."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for value in var.shared_data_allowed_ipv4_cidrs :
      can(cidrnetmask(strcontains(value, "/") ? value : "${value}/32")) &&
      (strcontains(value, "/") ? try(tonumber(split("/", value)[1]) > 0 && tonumber(split("/", value)[1]) < 31, false) : true)
    ])
    error_message = "shared_data_allowed_ipv4_cidrs must contain individual IPv4 addresses or CIDRs with prefix lengths 1-30. Use individual addresses for /31 and /32 storage rules."
  }
}
