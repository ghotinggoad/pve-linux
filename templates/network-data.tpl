network:
  version: 2
  ethernets:
    %{~ for nic_name, nic in nics ~}
    ${nic_name}:
      match:
        macaddress: "${nic.mac_address}"
      set-name: ${nic_name}
      dhcp4: no
      addresses:
        - ${nic.ip_address}/${nic.prefix_length}
      %{~ if length(nic.gateway) > 0 ~}
      routes:
        - to: 0.0.0.0/0
          via: ${nic.gateway}
      %{~ endif ~}
      nameservers:
        addresses:
          %{~ for dns_server in nic.dns_servers ~}
          - ${dns_server}
          %{~ endfor ~}
    %{~ endfor ~}
