variable "proxmox_endpoint" {
  description = "HTTPS URL of the Proxmox VE API."
  type        = string
}

variable "proxmox_api_token" {
  description = "Proxmox API token in user@realm!tokenid=secret format."
  type        = string
  sensitive   = true
}

variable "proxmox_node" {
  description = "Target Proxmox node name."
  type        = string
}

variable "template_vm_id" {
  description = "ID of an existing VM template available to the API token."
  type        = number
}

variable "vm_id" {
  description = "Unused VM ID approved by the Proxmox administrator."
  type        = number
}
