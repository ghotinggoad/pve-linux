#cloud-config
hostname: ${hostname}
disable_root: true
ssh_pwauth: false
users:
  - name: ${ssh_username}
    sudo: ALL=(ALL) NOPASSWD:ALL
    lock_passwd: true
    ssh_authorized_keys:
    - "${ssh_public_key}"
growpart:
  mode: auto
resize_rootfs: true
write_files:
  %{~ if length(nics) > 0 ~}
  - path: /etc/systemd/system/policy-based-routing.service
    permissions: "0644"
    content: |
      ${indent(6, chomp(pbr_service))}
  %{~ endif ~}
runcmd:
  %{~ if length(nics) > 0 ~}
  - ["systemctl", "enable", "--now", "policy-based-routing.service"]
  %{~ endif ~}
