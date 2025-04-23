resource "proxmox_vm_qemu" "talos_vm" {
  count            = var.node_count
  target_node      = var.pm_host
  clone            = var.vm_talos_tmpl_name
  qemu_os          = "l26"
  name             = "${var.vm_name_prefix}-${format("%02d", count.index + 1)}"
  agent            = 1
  onboot           = var.vm_onboot
  cores            = var.vm_max_vcpus
  vcpus            = var.vm_vcpus
  sockets          = var.vm_sockets
  cpu_type         = var.vm_cpu_type
  memory           = var.vm_memory_mb
  scsihw           = "virtio-scsi-single"
  boot             = "order=scsi0;net0;ide0"
  hotplug          = "disk,network,usb"
  numa             = true
  automatic_reboot = false
  vm_state         = "stopped"
  desc             = "This VM is managed by Terraform, cloned from an Talos image"
  tags             = var.vm_tags

  disks {
    ide {
      ide0 {
        cdrom {
          iso = "local:iso/metal-amd64.iso"
        }
      }
    }
    scsi {
      scsi0 {
        disk {
          size     = "100G"
          storage  = "pmoxpool01"
          iothread = true
        }
      }
    }
  }

  network {
    id       = 0
    model    = "virtio"
    bridge   = "vmbr0"
    firewall = false
  }

  ipconfig0 = "ip=${cidrhost(var.vm_net_subnet_cidr, var.vm_host_number + count.index)}${local.vm_net_subnet_mask},gw=${local.vm_net_default_gw}"

  ciuser = var.vm_user
  lifecycle {
    create_before_destroy = true
  }
}
