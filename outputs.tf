output"ansible_inventory" {
  value = {
    "all" = {
      "children" = {for template_name, template in var.templates: template_name => {
        "hosts" = {for vm in local.vms: vm.hostname => {
          "ansible_host" = vm.nics[vm.ssh.nic].ip_address
        }if vm.group == template_name}
      }}
    }
  }
}
