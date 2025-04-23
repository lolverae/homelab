#!/bin/bash

if [ ! -f .talos_ips ]; then
    echo "Error: .talos_ips file not found. Please create a .env file with the following variables:"
    echo "CONTROL_PLANE_IPS=ip1,ip2,ip3"
    echo "WORKER_IPS=ip1,ip2,ip3"
    exit 1
fi

source .talos_ips

if [ -z "$CONTROL_PLANE_IPS" ] || [ -z "$WORKER_IPS" ]; then
    echo "Error: Missing required env variables CONTROL_PLANE_IPS or WORKER_IPS"
    exit 1
fi

OUTPUT_DIR="_out"
mkdir -p "$OUTPUT_DIR"

generate_configs() {
    # Use the first control plane IP as the endpoint
    IFS=',' read -ra CONTROL_PLANE_ARRAY <<< "$CONTROL_PLANE_IPS"
    FIRST_CONTROL_PLANE_IP="${CONTROL_PLANE_ARRAY[0]}"
    
    echo "Generating Talos configurations"
    
    # Generate cluster configurations using first control plane IP
    talosctl gen config talos-proxmox-cluster "https://$FIRST_CONTROL_PLANE_IP:6443" --output-dir "$OUTPUT_DIR"
    
    if [ $? -ne 0 ]; then
        echo "Failed to generate Talos configurations"
        exit 1
    fi
}

apply_control_plane_configs() {
    IFS=',' read -ra CONTROL_PLANE_ARRAY <<< "$CONTROL_PLANE_IPS"
    
    echo "Applying configurations to control plane nodes:"
    for node_ip in "${CONTROL_PLANE_ARRAY[@]}"; do
        echo "Configuring control plane node: $node_ip"
        talosctl apply-config --insecure --nodes "$node_ip" --file "$OUTPUT_DIR/controlplane.yaml"
        
        if [ $? -ne 0 ]; then
            echo "Failed to apply configuration to control plane node: $node_ip"
            exit 1
        fi
    done
}

apply_worker_configs() {
    IFS=',' read -ra WORKER_ARRAY <<< "$WORKER_IPS"
    
    echo "Applying configurations to worker nodes:"
    for node_ip in "${WORKER_ARRAY[@]}"; do
        echo "Configuring worker node: $node_ip"
        talosctl apply-config --insecure --nodes "$node_ip" --file "$OUTPUT_DIR/worker.yaml"
        
        if [ $? -ne 0 ]; then
            echo "Failed to apply configuration to worker node: $node_ip"
            exit 1
        fi
    done
}

main() {
    generate_configs
    apply_control_plane_configs
    apply_worker_configs
    
    echo "Cluster configuration complete!"
}

main
