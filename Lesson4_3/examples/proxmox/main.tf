terraform {
  required_version = ">= 1.6.0"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.70, < 1.0"
    }
  }
}

provider "proxmox" {
  endpoint  = var.proxmox_endpoint
  api_token = var.proxmox_api_token
}

resource "proxmox_virtual_environment_vm" "lesson" {
  name      = "terraform-lesson43-demo"
  node_name = var.proxmox_node
  vm_id     = var.vm_id

  clone {
    vm_id = var.template_vm_id
    full  = true
  }

  cpu {
    cores = 2
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = 2048
  }
}
