# 🚀 Proxmox + Talos + Flux Homelab

This repository automates the deployment of a complete Kubernetes homelab infrastructure on Proxmox using:

- 🛠️ *Terraform* - Infrastructure as Code for VM provisioning
- 🧊 *Talos Linux* - Secure, immutable Kubernetes OS
- 🌊 *Flux CD* - GitOps continuous delivery for cluster management
- ☸️ *Kubernetes* - Container orchestration platform

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Repository Structure](#repository-structure)
- [Detailed Setup](#detailed-setup)
- [Applications](#applications)
- [Maintenance](#maintenance)
- [Troubleshooting](#troubleshooting)

## 🎯 Overview

This homelab setup provides:

- *High Availability*: Multi-node Kubernetes cluster with control plane redundancy
- *GitOps Workflow*: All cluster configuration managed via Git
- *Production-Ready Apps*: Traefik, MetalLB, cert-manager, monitoring stack, and more
- *Automated Deployment*: End-to-end automation from VM provisioning to app deployment

## 🏗️ Architecture


┌─────────────────────────────────────────────────────────┐
│                    Proxmox Cluster                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐   │
│  │ Control      │  │ Control      │  │ Control      │   │
│  │ Plane 1      │  │ Plane 2      │  │ Plane 3      │   │
│  └──────────────┘  └──────────────┘  └──────────────┘   │
│  ┌──────────────┐  ┌──────────────┐                     │
│  │ Worker 1     │  │ Worker 2     │                     │
│  └──────────────┘  └──────────────┘                     │
└─────────────────────────────────────────────────────────┘
                        │
                        ▼
            ┌───────────────────────┐
            │   Talos Kubernetes    │
            │      Cluster          │
            └───────────────────────┘
                        │
                        ▼
    ┌───────────────────────────────────────┐
    │         Flux CD GitOps                │
    │  ┌──────────┐      ┌──────────┐       │
    │  │ Infra    │ ───> │ Apps     │       │
    │  │ Layer    │      │ Layer    │       │
    │  └──────────┘      └──────────┘       │
    └───────────────────────────────────────┘


## 🔧 Prerequisites

### Required Software

- [Terraform](https://www.terraform.io/) (or OpenTofu) >= 1.0
- [talosctl](https://www.talos.dev/) >= 1.5
- [kubectl](https://kubernetes.io/docs/tasks/tools/) >= 1.28
- [flux CLI](https://fluxcd.io/flux/installation/) >= 2.0

### Proxmox Requirements

- Proxmox VE cluster with API access
- API token with appropriate permissions (see Terraform setup)
- Network configured for Kubernetes nodes
- Storage configured (Ceph recommended for PVCs)

### Network Requirements

- Static IP addresses for all nodes
- DNS resolution (optional but recommended)
- LoadBalancer IP pool for MetalLB (see configuration)

## 🚀 Quick Start

### 1. Clone the Repository

```
git clone https://github.com/yourusername/homelab.git
cd homelab
```


### 2. Provision VMs with Terraform

```
cd terraform
# Configure your variables (see terraform/README.md)
terraform init
terraform plan
terraform apply
```


### 3. Bootstrap Talos Cluster

```
cd ../talos
cp .talos_ips.example .talos_ips
# Edit .talos_ips with your node IPs
./setup.sh
```


### 4. Get Kubeconfig

```
talosctl kubeconfig
kubectl get nodes
```


### 5. Install Flux CD

```
flux install
flux create source git flux-system \
  --url=https://github.com/yourusername/homelab \
  --branch=main \
  --path=./gitops/clusters/totorolab
```


## 📁 Repository Structure


homelab/
├── README.md                 # This file
├── terraform/                # Infrastructure provisioning
│   ├── main.tf              # Main Terraform configuration
│   ├── variables.tf         # Variable definitions
│   ├── modules/             # Reusable Terraform modules
│   │   ├── talos_vm/       # Talos VM module
│   │   └── alma_lxc/       # AlmaLinux LXC module
│   └── README.md           # Terraform documentation
├── talos/                    # Talos cluster bootstrap
│   ├── setup.sh             # Bootstrap script
│   ├── .talos_ips.example  # Example IP configuration
│   └── README.md           # Talos documentation
└── gitops/                  # Flux CD GitOps configuration
    └── clusters/
        └── totorolab/       # Cluster-specific config
            ├── flux-system/         # Flux bootstrap
            ├── infrastructure/      # Infrastructure layer
            │   └── base/           # HelmRepos & Namespaces
            ├── apps/               # Application layer
            │   └── base/           # HelmReleases
            │       ├── cert-manager/
            │       ├── traefik/
            │       ├── metallb/
            │       ├── grafana/
            │       ├── prometheus/
            │       ├── homarr/
            │       └── nextcloud/
            └── infrastructure.yaml  # Flux Kustomizations


## 📖 Detailed Setup

### Step 1: Terraform VM Provisioning

See [terraform/README.md](terraform/README.md) for detailed instructions.

*Quick steps:*

1. Create Proxmox API token:
   ```
   pveum role add TerraformProv -privs "Datastore.AllocateSpace Datastore.Audit Pool.Allocate Sys.Audit Sys.Console Sys.Modify VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.Cloudinit VM.Config.CPU VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Migrate VM.Monitor VM.PowerMgmt SDN.Use"
   pveum user add terraform-prov@pve --password <password>
   pveum aclmod / -user terraform-prov@pve -role TerraformProv
   pveum user token add terraform-prov@pve tftoken
   ```
   

2. Configure variables in terraform/terraform.tfvars:
   hcl
   proxmox_node           = "pve01"
   proxmox_api_url        = "https://your.proxmox.local:8006/api2/json"
   proxmox_api_token_id   = "terraform-prov@pve!tftoken"
   proxmox_api_token_secret = "your-secret"
   

3. Deploy:
   ```
   cd terraform
   terraform init
   terraform apply
   ```
   

### Step 2: Talos Cluster Bootstrap

See [talos/README.md](talos/README.md) for detailed instructions.

*Quick steps:*

1. Configure node IPs:
   ```
   cd talos
   cp .talos_ips.example .talos_ips
   ```
   

2. Run bootstrap:
   ```
   ./setup.sh
   ```
   

3. Get kubeconfig:
   ```
   talosctl kubeconfig
   kubectl get nodes
   ```
   

### Step 3: Flux CD GitOps Setup

1. Install Flux:
   ```
   flux install
   ```
   

2. Create Git source:
   ```
   flux create source git flux-system \
     --url=https://github.com/yourusername/homelab \
     --branch=main \
     --path=./gitops/clusters/totorolab
   ```
   

3. Flux will automatically sync:
   - Infrastructure layer (HelmRepos, Namespaces)
   - Application layer (HelmReleases)

## 🎯 Applications

The following applications are deployed via Flux CD:

### Infrastructure

- *Traefik* - Ingress controller and reverse proxy
  - Dashboard: http://totorolab.local/dashboard/
- *MetalLB* - LoadBalancer implementation
  - IP Pool: 192.168.10.240 - 192.168.4.250
- *cert-manager* - Certificate management
  - Let's Encrypt integration configured

### Monitoring

- *Prometheus* - Metrics collection and alerting
- *Grafana* - Visualization and dashboards
  - Access: http://grafana.totorolab.local

### Applications

- *Homarr* - Dashboard and homepage
- *Nextcloud* - File storage and collaboration
  - Access: http://nextcloud.totorolab.local

## 🔧 Configuration

### MetalLB IP Pool

Configured in gitops/clusters/totorolab/apps/base/metallb/config.yaml:

yaml
addresses:
  - 192.168.10.240 - 192.168.4.250


### Certificates

cert-manager is configured with Let's Encrypt. Update the email in:
gitops/clusters/totorolab/apps/base/cert-manager/config.yaml

### Storage

The cluster uses Ceph-backed PVCs via the k8s-cephfs storage class.

## 🔄 Maintenance

### Updating Applications

All applications are managed via GitOps. To update:

1. Edit the HelmRelease in gitops/clusters/totorolab/apps/base/<app>/
2. Commit and push changes
3. Flux will automatically reconcile

### Adding New Applications

1. Create a new directory in gitops/clusters/totorolab/apps/base/<app-name>/
2. Add helmrelease.yaml and kustomization.yaml
3. Update gitops/clusters/totorolab/apps/base/kustomization.yaml
4. Commit and push

### Cluster Updates

For Talos cluster updates:

```
talosctl upgrade --nodes <node-ip> --image <new-image>
```


## 🐛 Troubleshooting

### Flux Sync Issues

```
# Check Flux status
flux get all

# Check Kustomization status
flux get kustomizations

# Force reconciliation
flux reconcile source git flux-system
flux reconcile kustomization infrastructure
flux reconcile kustomization apps
```


### Application Issues

```
# Check HelmRelease status
kubectl get helmreleases -A

# Check pod status
kubectl get pods -A

# View logs
kubectl logs -n <namespace> <pod-name>
```


### Network Issues

```
# Check MetalLB status
kubectl get ipaddresspool -n metallb
kubectl get l2advertisement -n metallb

# Check Traefik ingress
kubectl get ingressroutes -A
```



## 📝 Notes

- *Secrets Management*: Currently unmanaged. Consider using [Sealed Secrets](https://github.com/bitnami-labs/sealed-secrets) or [SOPS](https://github.com/mozilla/sops) for production.
- *Backup*: Implement regular backups for etcd and persistent volumes.
- *Monitoring*: Prometheus and Grafana are configured but may need additional alerting rules.
- *Security*: Review RBAC policies and network policies for your environment.

## 🙏 Acknowledgments

- [Talos Linux](https://www.talos.dev/) - Immutable Kubernetes OS
- [Flux CD](https://fluxcd.io/) - GitOps toolkit
- [Terraform](https://www.terraform.io/) - Infrastructure as Code
- All the amazing open-source projects that make this possible
