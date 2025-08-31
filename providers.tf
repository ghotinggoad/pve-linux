provider "proxmox" {
  endpoint = "https://${var.proxmox.api_endpoint}:8006"
  api_token = "${var.proxmox.api_token_id}=${var.proxmox.api_token_key}"
  insecure = var.proxmox.tls_insecure
  ssh {
    agent = true
    username = var.proxmox.ssh.username
    dynamic "node" {
      for_each = var.proxmox.ssh.nodes
      content {
        name = node.key
        address = node.value.ip_address
      }
    }
  }
}

provider "cloudinit" {}
