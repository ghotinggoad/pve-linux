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
    root_vdisk = object({
      interface = optional(string, "scsi0")
      path = optional(string, "/dev/sda")
      size = number
      cloud_image_filename = string
      iothread = optional(bool, false)
    })
    data_vdisks = optional(map(object({
      interface = string
      path = string
      size = number
      iothread = optional(bool, false)
      persistent_mounts = optional(map(object({
        size = string
        fstype = string
        mount_target = string
        mount_options = optional(string, "defaults")
      })))
    })), {})
    tmpfs_mounts = optional(map(object({
      size = string
      mount_target = string
      mount_options = optional(string, "defaults")
    })))
    nics = map(object({
      default = optional(bool, false)
      bridge = string
      vlan_tag = optional(number)
      cidr = string
      ip_offset = number
      gateway = string
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
