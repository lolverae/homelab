## Proxmox Provisioning with Terraform

This repository contains Terraform code to deploy VMs and containers on a
Proxmox cluster.

### Requirements

- Terraform installed ([https://www.terraform.io/](https://www.terraform.io/))
- Proxmox cluster with API access enabled
  ([https://pve.proxmox.com/wiki/Proxmox_VE_API](https://pve.proxmox.com/wiki/Proxmox_VE_API))
- Terraform provider for Proxmox
  ([https://registry.terraform.io/providers/Telmate/proxmox/latest/docs](https://registry.terraform.io/providers/Telmate/proxmox/latest/docs))

### Variables

- `proxmox_node`: Name of the Proxmox node to deploy the container.
- `proxmox_api_url`: URL of the Proxmox VE API endpoint.
- `proxmox_api_token_id`: API token ID with appropriate permissions.
- `proxmox_api_token_secret`: API token secret associated with the token ID.
- `ct_password`: Password for the unprivileged user account.

### Usage

1. Clone this repository.
2. Create a Terraform user on your Proxmox cluster:
   ```bash
   pveum role add TerraformProv -privs "Datastore.AllocateSpace Datastore.Audit Pool.Allocate Sys.Audit Sys.Console Sys.Modify VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.Cloudinit VM.Config.CPU VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Migrate VM.Monitor VM.PowerMgmt SDN.Use" 
   pveum user add terraform-prov@pve --password <password>
   pveum aclmod / -user terraform-prov@pve -role TerraformProv
   pveum user token add  terraform-prov@pve tftoken
   ```

3. Create a `.tfvars` file in the same directory with your variable definitions:

```
variable "proxmox_node" {
  type = string
}

variable "proxmox_api_url" {
  type = string
}

variable "proxmox_api_token_id" {
  type = string
}

variable "proxmox_api_token_secret" {
  type = string
 sensitive = true
}

variable "ct_password" {
  type = string
  sensitive = true
}
```

4. Update the variable values according to your environment.
5. Run `terraform init` to initialize the Terraform configuration.
6. Run `terraform plan` to preview the changes that will be made.
7. Run `terraform apply` to create the desired config on your Proxmox cluster.
