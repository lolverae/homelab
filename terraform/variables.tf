# Environment
########################################################################
variable "env_name" {
  type    = string
  default = "test"
}

variable "vm_talos_tmpl_name" {
  type        = string
  description = "Name of iso image for Talos."
  default     = "talos"
}

variable "pm_host1" {
  type    = string
  default = "pve1"
}

variable "pm_host2" {
  type    = string
  default = "pve2"
}

# variable "pm_host3" {
#   type    = string
#   default = "pve3"
# }

# variable "alma_container_password" {
#   type        = string
#   sensitive   = true
#   description = "Password for the alma container"
# }
#
# variable "alma_os_template" {
#   type        = string
#   description = "LXC template for alma container"
# }

variable "node_tag" {
  type    = string
  default = "node"
}

variable "controller_tag" {
  type    = string
  default = "ctrl"
}

# Common infrastructure
########################################################################
variable "internal_net_name" {
  type        = string
  description = "Name of the internal network bridge"
  default     = "vmbr0"
}

variable "internal_net_subnet_cidr" {
  type        = string
  description = "CIDR of the internal network"
  default     = "10.0.1.0/24"
}

variable "vm_user" {
  type        = string
  description = "The default user for all VMs"
  default     = "talos"
}

variable "vm_sockets" {
  type        = number
  description = "Number of the CPU socket to allocate to the VMs"
  default     = 1
}

variable "vm_max_vcpus" {
  type        = number
  description = "The maximum CPU cores available per CPU socket to allocate to the VM"
  default     = 2
}

variable "vm_cpu_type" {
  type        = string
  description = "The type of CPU to emulate in the Guest"
  default     = "host"
}

variable "vm_os_disk_storage" {
  type        = string
  description = "Default storage pool where OS VM disk is placed"
  default     = "local"
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
  default = true
}
variable "pm_host" {
  type        = string
  description = "The name of Proxmox node where the VM is placed."
}

