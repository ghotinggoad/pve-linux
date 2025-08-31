#cloud-config
hostname: ${hostname}
disable_root: true
ssh_pwauth: false
users:
  - name: ${ssh_username}
    sudo: ALL=(ALL) NOPASSWD:ALL
    lock_passwd: true
    ssh_authorized_keys:
    - ${ssh_public_key}
growpart:
  mode: auto
  ignore_growroot_disabled: false
resize_rootfs: true
