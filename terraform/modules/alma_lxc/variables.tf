variable "vm_name_prefix" {
  type        = string
  description = "VM prefix name"
  default     = "vm"
}

variable "alma_count" {
  type        = number
  description = "Amount of alma containers to create"
}

variable "os_template" {
  type        = string
  description = "LXC template for alma container"
}

variable "ct_password" {
  type        = string
  sensitive   = true
  description = "Password for the alma container"
}

# Proxmox VE
########################################################################
variable "pm_api_url" {
  type        = string
  description = "The base URL for Proxmox VE API. See https://pve.proxmox.com/wiki/Proxmox_VE_API#API_URL"
}
variable "pm_api_token_id" {
  type        = string
  description = "The token ID to access Proxmox VE API."
}
variable "pm_api_token_secret" {
  type        = string
  description = "The UUID/secret of the token defined in the variable `pm_api_token_id`."
  sensitive   = true
}
variable "pm_tls_insecure" {
  type        = bool
  description = "Disable TLS verification while connecting to the Proxmox VE API server."
}
variable "pm_host" {
  type        = string
  description = "The name of Proxmox node where the VM is placed."
}

variable "pm_parallel" {
  type        = number
  description = "The number of simultaneous Proxmox processes. E.g: creating resources."
  default     = 1
}

variable "pm_timeout" {
  type        = number
  description = "Timeout value (seconds) for proxmox API calls."
  default     = 600
}

