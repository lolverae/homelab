# Talos Cluster Bootstrap

This directory contains scripts and configuration for bootstrapping a Talos Linux Kubernetes cluster.

## Prerequisites

- [talosctl](https://www.talos.dev/) installed and in your PATH
- VMs provisioned with Talos Linux (via Terraform or manually)
- Network access to all cluster nodes
- .talos_ips file configured with your node IPs

## Quick Start

1. *Copy the example configuration file:*
```
   cp .talos_ips.example .talos_ips
```
   

2. *Edit .talos_ips with your actual node IPs:*
   ```
   CONTROL_PLANE_IPS=192.168.1.10,192.168.1.11,192.168.1.12
   WORKER_IPS=192.168.1.20,192.168.1.21
   ```
   

3. *Make the setup script executable:*
   ```
   chmod +x setup.sh
   ```

4. *Run the bootstrap script:*
   ```
   ./setup.sh
   ```
   

5. *Get your kubeconfig:*
   ```
   talosctl kubeconfig
   ```
   

## What the Script Does

The setup.sh script will:

1. Validate dependencies
2. Validate IP addresses in .talos_ips
3. Generate Talos configuration files
4. Apply configurations to all control plane nodes
5. Apply configurations to all worker nodes
6. Provide instructions for getting kubeconfig

## Configuration File Format

The .talos_ips file should contain:

bash
CONTROL_PLANE_IPS=ip1,ip2,ip3
WORKER_IPS=ip1,ip2


- *CONTROL_PLANE_IPS*: Comma-separated list of control plane node IPs
  - Minimum: 1 node
  - Recommended: 3 nodes for high availability
- *WORKER_IPS*: Comma-separated list of worker node IPs
  - Minimum: 1 node

## Output

The script generates configuration files in the _out/ directory:

- controlplane.yaml - Control plane node configuration
- worker.yaml - Worker node configuration
- talosconfig - Talos client configuration

## Troubleshooting

### Node not responding

If a node doesn't respond after applying configuration:

1. Check if the node is powered on and accessible:
   bash
   ping <node-ip>
   

2. Check Talos node status:
   bash
   talosctl --nodes <node-ip> version
   

3. Check cluster health:
   bash
   talosctl --nodes <control-plane-ip> health
   

### Configuration errors

If you see configuration errors:

1. Verify your IP addresses are correct in .talos_ips
2. Ensure all nodes are running Talos Linux
3. Check network connectivity to all nodes
4. Review the generated configs in _out/ directory

### Getting kubeconfig fails

If talosctl kubeconfig fails:

1. Wait a few minutes for the cluster to fully bootstrap
2. Check that the first control plane node is ready:
   bash
   talosctl --nodes <first-control-plane-ip> health
   
3. Try specifying a specific node:
   bash
   talosctl kubeconfig --nodes <control-plane-ip>
   

## Manual Steps

If you prefer to run the steps manually:

1. *Generate configs:*
   bash
   talosctl gen config talos-proxmox-cluster https://<first-control-plane-ip>:6443 --output-dir _out
   

2. *Apply to control plane nodes:*
   bash
   talosctl apply-config --insecure --nodes <control-plane-ip> --file _out/controlplane.yaml
   

3. *Apply to worker nodes:*
   bash
   talosctl apply-config --insecure --nodes <worker-ip> --file _out/worker.yaml
   

4. *Get kubeconfig:*
   bash
   talosctl kubeconfig
   

## Security Notes

- The script uses --insecure flag for initial bootstrap (required for Talos)
- After bootstrap, Talos uses mTLS for all communication
- Keep your .talos_ips file secure and don't commit it to git
- The _out/ directory contains sensitive configuration - don't commit it
