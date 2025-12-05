output "ansible_inventory" {
  value = {
    "all" = {
      "children" = {for template_name, template in var.templates: template_name => {
        "hosts" = {for vm in local.vms: vm.hostname => {
          "ansible_host" = vm.nics[vm.ssh.nic].ip_address
          "ansible_user" = vm.ssh.username
          "ansible_ssh_common_args" = "-o StrictHostKeyChecking=accept-new"
        }if vm.template_name == template_name}
        "vars" = {
          "tmpfs_mounts" = {for tmpfs_mount_name, tmpfs_mount in template.tmpfs_mounts: tmpfs_mount_name => {
            "size" = tmpfs_mount.size
            "mount_target" = tmpfs_mount.mount_target
            "mount_options" = tmpfs_mount.mount_options
          }}
          "data_vdisks" = {for vdisk_name, vdisk in template.data_vdisks: vdisk_name => {
            "interface" = vdisk.interface
            "size" = vdisk.size
            "persistent_mounts" = vdisk.persistent_mounts
          }}
        }
      }}
    }
  }
}
