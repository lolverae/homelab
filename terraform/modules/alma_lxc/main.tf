resource "proxmox_lxc" "alma_lxc" {
  count        = var.alma_count
  target_node  = var.pm_host
  hostname     = "${var.vm_name_prefix}-${format("%02d", count.index + 1)}"
  ostemplate   = var.os_template
  password     = var.ct_password
  unprivileged = true
  cores        = 1
  memory       = 1024

  rootfs {
    storage = "local-lvm"
    size    = "5G"
  }

  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = "dhcp"
  }

  start = true
}

