# 🚀 Proxmox + Talos + Flux Homelab

This repo automates spinning up a full Kubernetes cluster on a Proxmox homelab
using:

- 🛠️ **Terraform** to provision VMs
- 🧊 **Talos Linux** to bootstrap a secure K8s cluster
- 🌊 **Flux** to GitOps-manage cluster apps like Traefik, MetalLB, and Homarr

---

## 🔧 Requirements

Make sure you have:

- [Terraform](https://www.terraform.io/) installed
- A Proxmox cluster with API access
  ([Proxmox API Docs](https://pve.proxmox.com/wiki/Proxmox_VE_API))
- [Telmate Proxmox Terraform Provider](https://registry.terraform.io/providers/Telmate/proxmox/latest/docs)
- [talosctl](https://www.talos.dev/) installed
- [flux CLI](https://fluxcd.io/flux/installation/)
- Proxmox cluster with:
  - VMs ready for Talos (no cloud-init needed)
  - Ceph storage configured for PVCs
  - MetalLB-ready network (see IP pool below, but setup whatever)

---

## 📁 Repo Layout

```
.
├── terraform/            # Terraform config for Proxmox VMs
├── clusters/
│   ├── apps/             # Flux HelmReleases for Homarr, Traefik, MetalLB
│   ├── flux-system/      # Flux bootstrap files
│   └── infrastructure/   # HelmRepositories and other infra definitions
└── talos-setup.sh        # Talos bootstrap script
```

---

## 🏗️ Step 1: Provision VMs with Terraform

1. Clone the repo.
2. Set up a Proxmox Terraform user:
   ```bash
   pveum role add TerraformProv -privs "Datastore.AllocateSpace Datastore.Audit Pool.Allocate Sys.Audit Sys.Console Sys.Modify VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.Cloudinit VM.Config.CPU VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Migrate VM.Monitor VM.PowerMgmt SDN.Use"
   pveum user add terraform-prov@pve --password <password>
   pveum aclmod / -user terraform-prov@pve -role TerraformProv
   pveum user token add terraform-prov@pve tftoken
   ```

3. Create a `.tfvars` file:
   ```hcl
   proxmox_node           = "pve01"
   proxmox_api_url        = "https://your.proxmox.local:8006/api2/json"
   proxmox_api_token_id   = "terraform-prov@pve!tftoken"
   proxmox_api_token_secret = "your-secret"
   ct_password            = "optional-if-used"
   ```

4. Run Terraform:
   ```bash
   cd terraform
   tofu init
   tofu plan
   tofu apply
   ```

---

## 🧊 Step 2: Bootstrap Talos Cluster

After VMs are up:

1. Create a `.talos_ips` file with your VM IPs:
   ```bash
   CONTROL_PLANE_IPS=<Your Control Plane IPs>
   WORKER_IPS=<Your Worker IPs>
   ```

2. Run the Talos bootstrap script:
   ```bash
   ./talos-setup.sh
   ```

This will:

- Generate configs using `talosctl gen config`
- Apply control plane and worker configs
- Get you a ready-to-go Talos K8s cluster ✅

---

## 🌊 Step 3: GitOps with Flux

Once your cluster is up:

1. Make sure Flux is installed and initialized on the target cluster
2. Flux will automatically sync configs from this repo:
   - `clusters/apps/` – Homarr, Traefik, MetalLB
   - `clusters/infrastructure/` – Helm repos
   - `clusters/flux-system/` – Flux system config

---

## 🧠 Notes

- MetalLB IP pool:
  ```yaml
  addresses:
    - 192.168.100.240 - 192.168.100.250
  ```

- Traefik dashboard: `http://totorolab.local/dashboard/`
- Storage: Ceph-backed PVCs via `k8s-cephfs` storage class
- Secrets: Currently unmanaged – use SealedSecrets or SOPS if needed
