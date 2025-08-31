variable "proxmox"{
  type = object({
    tls_insecure = bool
    api_endpoint = string
    api_token_id = string
    api_token_key = string
    datastores = object({
      snippets = string
      imports = string
      domains = string
      backups = string
    })
    ssh = object({
      username = string
      nodes = optional(map(object({
        ip_address = string
      })), {})
    })
  })
}

variable "templates"{
  type = map(object({
    node = string
    count = number
    id_offset = number
    hostname_prefix = string
    vcpu_count = number
    affinity = optional(string)
    memory_size_min = number
    memory_size_max = optional(number)
    vdisks = optional(map(object({
      size = number
      cloud_image_filename = optional(string)
      iothread = optional(bool, false)
    })), {})
    nics = map(object({
      bridge = string
      vlan_tag = optional(number)
      cidr = string
      ip_offset = number
      gateway = optional(string)
      dns_servers = optional(list(string), [])
    }))
    pci_devices = optional(map(object({
      host_address = string
    })), {})
    ssh = object({
      nic = string
      username = string
      public_key = string
    })
  }))
}
