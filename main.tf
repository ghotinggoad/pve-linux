locals{
  vms = merge([for template_name, template in var.templates: {for i in range(template.count): template.id_offset+i => {
    group = template_name
    node = template.node
    hostname = (template.count > 1) ? "${template.hostname_prefix}${i+1}" : template.hostname_prefix
    vcpu_count = template.vcpu_count
    memory_size_min = template.memory_size_min * 1024
    memory_size_max = (template.memory_size_max != null) ? template.memory_size_max * 1024 : template.memory_size_min
    vdisks = {for vdisk_name, vdisk in template.vdisks: vdisk_name => {
      datastore_id = var.proxmox.datastores.domains
      interface = "scsi${index(keys(template.vdisks), vdisk_name)+1}"
      size = vdisk.size
      cloud_image_id = (vdisk.cloud_image_filename != null) ? "${var.proxmox.datastores.imports}:import/${vdisk.cloud_image_filename}" : null
      iothread = vdisk.iothread
    }}
    nics = {for nic_name, nic in template.nics: nic_name => {
      bridge = nic.bridge
      vlan_tag = nic.vlan_tag
      mac_address = format("52:54:00:%02d:%02d:%02d", split(".", nic.cidr)[2], nic.ip_offset+i, index(keys(template.nics), nic_name))
      ip_address = cidrhost(nic.cidr, nic.ip_offset+i)
      prefix_length = split("/", nic.cidr)[1]
      gateway = nic.gateway
      dns_servers = nic.dns_servers
    }}
    pci_devices = {for pci_device_name, pci_device in template.pci_devices: pci_device_name => {
      device = "hostpci${index(keys(template.pci_devices), pci_device_name)}"
      host_address = pci_device.host_address
      pcie = pci_device.pcie
      }
    }
    ssh = template.ssh
  }}]...)
}

resource "proxmox_virtual_environment_file" "meta_data_cidata" {
  for_each = local.vms
  content_type = "snippets"
  datastore_id = var.proxmox.datastores.snippets
  node_name = each.value.node
  source_raw {
    data = templatefile("${path.module}/templates/meta-data.tpl", {
      hostname = each.value.hostname
    })
    file_name = "${each.key}-meta-data.yml"
  }
}

resource "proxmox_virtual_environment_file" "user_data_cidata" {
  for_each = local.vms
  content_type = "snippets"
  datastore_id = var.proxmox.datastores.snippets
  node_name = each.value.node
  source_raw {
    data = templatefile("${path.module}/templates/user-data.tpl", {
      hostname = each.value.hostname
      ssh_username = each.value.ssh.username
      ssh_public_key = each.value.ssh.public_key
    })
    file_name = "${each.key}-user-data.yml"
  }
}

resource "proxmox_virtual_environment_file" "network_data_cidata" {
  for_each = local.vms
  content_type = "snippets"
  datastore_id = var.proxmox.datastores.snippets
  node_name = each.value.node
  source_raw {
    data = templatefile("${path.module}/templates/network-data.tpl", {
      nics = each.value.nics
    })
    file_name = "${each.key}-network-data.yml"
  }
}

resource "proxmox_virtual_environment_vm" "vms" {
  for_each = local.vms
  vm_id = each.key
  name = each.value.hostname
  node_name = each.value.node
  bios = "ovmf"
  machine = "q35"
  cpu {
    type = "host"
    cores = each.value.vcpu_count
  }
  memory {
    dedicated = each.value.memory_size_min
    floating = each.value.memory_size_max
  }
  efi_disk {
    datastore_id = var.proxmox.datastores.domains
    file_format = "raw"
    type = "4m"
    pre_enrolled_keys = true
  }
  dynamic "disk" {
    for_each = each.value.vdisks
    content {
      datastore_id = var.proxmox.datastores.domains
      interface = disk.value.interface
      size = disk.value.size
      file_format = "raw"
      import_from = disk.value.cloud_image_id
      iothread = disk.value.iothread
      discard = "on"
    }
  }
  dynamic "network_device" {
    for_each = each.value.nics
    content {
      bridge = network_device.value.bridge
      vlan_id = network_device.value.vlan_tag
      mac_address = network_device.value.mac_address
      firewall = false
    }
  }
  dynamic "hostpci" {
    for_each = each.value.pci_devices
    content {
      device = hostpci.value.device
      id = hostpci.value.host_address
    }
  }
  initialization {
    interface = "scsi0"
    datastore_id = var.proxmox.datastores.domains
    type = "nocloud"
    meta_data_file_id = proxmox_virtual_environment_file.meta_data_cidata[each.key].id
    user_data_file_id = proxmox_virtual_environment_file.user_data_cidata[each.key].id
    network_data_file_id = proxmox_virtual_environment_file.network_data_cidata[each.key].id
  }
  boot_order = [for vdisk in each.value.vdisks: vdisk.interface if vdisk.cloud_image_id != null]
  started = true
}
