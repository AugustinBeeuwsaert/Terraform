resource "proxmox_virtual_environment_vm" "proxmox" {
  name        = "front"
  node_name   = "proxmox1"  
  description = "VM créée avec Terraform"   
  vm_id       = 110  

  startup {
    order      = "3"
    up_delay   = 60
    down_delay = 60
  }

  cpu {
    cores = 2
  }

  memory {
    dedicated = 2048  
  }

  disk {
    datastore_id = "local-lvm"
    size         = 8     
    interface    = "scsi0"  
    file_format  = "raw"   
  }

  # Configuration du réseau
  network_device {
    bridge = "vmbr0"
  }

  # Configuration de l'initialisation (cloud-init, DHCP...)
  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }

  # Activation de l'agent Proxmox
  agent {
    enabled = true
  }

  cdrom {
    enabled = true
    file_id = "local:iso/preseeded_debian.iso"
  }
}



