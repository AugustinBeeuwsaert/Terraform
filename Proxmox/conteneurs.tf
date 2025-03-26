resource "proxmox_virtual_environment_container" "proxmox" {
  node_name   = "proxmox1"
  description = "Conteneur créé avec Terraform"
  vm_id       = 111  # ID du conteneur
  
  initialization {
    hostname = "front"

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }

  network_interface {
    name = "veth0"
  }

  operating_system {
    # Or you can use a volume ID, as obtained from a "pvesm list <storage>"
    template_file_id = "local:vztmpl/debian-12-standard_12.7-1_amd64.tar.zst"
    type             = "debian"
  }

  mount_point {
    # bind mount, *requires* root@pam authentication
    volume = "/mnt/bindmounts/shared"
    path   = "/mnt/shared"
  }

  mount_point {
    # volume mount, a new volume will be created by PVE
    volume = "local-lvm"
    size   = "8G"
    path   = "/mnt/volume"
  }

  startup {
    order      = "3"
    up_delay   = "60"
    down_delay = "60"
  }
}