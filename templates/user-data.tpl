#cloud-config
hostname: ${hostname}
disable_root: true
ssh_pwauth: false
users:
  - name: ${ssh_username}
    sudo: ALL=(ALL) NOPASSWD:ALL
    lock_passwd: false
    passwd: $6$B.ZaECEguANjLqi5$tUnZQj0vquaEwLKQfH0pi6X/QfK6vEhy9FIUGv2RvqsNpXGulp6OwH9FiJS.H0xqAsHD.eQ2JlAReOK8UJWev1
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
  %{~ if length(additional_vdisks) > 0 ~}
  - path: /usr/local/sbin/storage-setup.sh
    permissions: "0700"
    content: |
      ${indent(6, chomp(storage_setup_sh))}
  %{~ endif ~}
runcmd:
  %{~ if length(nics) > 0 ~}
  - ["systemctl", "enable", "--now", "policy-based-routing.service"]
  %{~ endif ~}
  %{~ if length(additional_vdisks) > 0 ~}
  - ["bash", "/usr/local/sbin/storage-setup.sh"]
  - ["rm", "/usr/local/sbin/storage-setup.sh"]
  - ["systemctl", "reboot"]
  %{~ endif ~}
