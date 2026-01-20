variable "vm_name_prefix" {
  type        = string
  description = "VM prefix name"
  default     = "vm"
}

variable "node_count" {
  type        = number
  description = ""
}

variable "vm_tags" {
  type    = string
  default = ""
}

variable "vm_net_name" {
  type        = string
  description = "vmbr0"
}

variable "vm_net_subnet_cidr" {
  type        = string
  description = "Address prefix for the internal network"
}


variable "vm_onboot" {
  type        = bool
  description = "Start the VM right after Proxmox host starts"
  default     = false
}

variable "vm_user" {
  type    = string
  default = "talos"
}

variable "vm_sockets" {
  type    = number
  default = 1
}

variable "vm_max_vcpus" {
  type        = number
  description = "The maximum CPU cores available per CPU socket to allocate to the VM."
  default     = 2
}

variable "vm_vcpus" {
  type        = number
  description = "The number of CPU cores to allocate to the VM. This should be less or equal to vm_max_vcpus."
  default     = 2
}

variable "vm_cpu_type" {
  type        = string
  description = "The type of CPU to emulate in the Guest"
  default     = "host"
}

variable "vm_memory_mb" {
  type        = number
  description = "The size of VM memory in MB"
  default     = 4000
}

variable "vm_os_disk_size_gb" {
  type        = number
  description = "The size of VM OS disk in Gigabyte"
  default     = 20
}

variable "vm_os_disk_storage" {
  type        = string
  description = "Default storage pool where OS VM disk is placed."
}

variable "vm_talos_tmpl_name" {
  type        = string
  description = "Name of iso image for Talos."
  default     = "talos"
}

variable "vm_host_number" {
  type        = number
  description = "The host number of the VM in the subnet"
}

variable "add_worker_node_data_disk" {
  type        = bool
  description = "A boolean value that indicates whether to add a data disk to each worker node of the cluster."
  default     = false
}

variable "worker_node_data_disk_storage" {
  type        = string
  description = "The storage pool where the data disk is placed."
  default     = ""
}

variable "worker_node_data_disk_size" {
  type        = string
  description = "The size of worker node data disk in Gigabyte."
  default     = 10
}


# Local vars

locals {
  vm_net_subnet_mask = "/${split("/", var.vm_net_subnet_cidr)[1]}"
  vm_net_default_gw  = cidrhost(var.vm_net_subnet_cidr, 1)
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

variable "module_depends_on" {
  description = "Optional dependencies for VM"
  type        = list(any)
  default     = []
}

