#cloud-config
hostname: ${hostname}
disable_root: true
ssh_pwauth: false
users:
  - name: ${ssh_username}
    sudo: ALL=(ALL) NOPASSWD:ALL
    lock_passwd: false
    passwd: $6$ZUtTCm4k4RKlnRNb$.LIrjE.OZEqYyxZitf3xwJ70DdUfhHkCP5sALLvlbdZvoNKxw4REFHMuhkzDFbVPHy.r5NLzlP3vrVvPG8AoF.
    ssh_authorized_keys:
    - ${ssh_public_key}
growpart:
  mode: auto
  ignore_growroot_disabled: false
resize_rootfs: true
write_files:
  - path: /etc/systemd/system/routing-policy.service
    permissions: "0644"
    content: |
      [Unit]
      After=network-online.target
      Wants=network-online.target
      [Service]
      Type=oneshot
      Environment=PATH=/usr/sbin:/usr/bin:/sbin:/bin
      %{~ for nic_name, nic in nics ~}
      %{~ if nic.default ~}
      ExecStart=/usr/bin/env ip -4 route replace default via ${nic.gateway} dev ${nic_name}
      %{~ endif ~}
      ExecStart=/usr/bin/env ip -4 route replace default via ${nic.gateway} dev ${nic_name} table ${nic.routing_table}
      ExecStart=/usr/bin/env ip -4 rule add pref ${nic.routing_table} from ${nic.ip_address}/32 lookup ${nic.routing_table}
      %{~ endfor ~}
      [Install]
      WantedBy=multi-user.target
runcmd:
  - ["systemctl", "enable", "--now", "routing-policy.service"]
