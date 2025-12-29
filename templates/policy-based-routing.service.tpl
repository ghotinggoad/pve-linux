[Unit]
After=network-online.target
Wants=network-online.target
[Service]
Type=oneshot
ExecStart=/usr/sbin/sysctl -w net.ipv6.conf.all.disable_ipv6=1
ExecStart=/usr/sbin/sysctl -w net.ipv6.conf.default.disable_ipv6=1
%{ for nic_name, nic in nics ~}
%{ if nic.default ~}
ExecStart=/usr/sbin/ip -4 route replace default via ${nic.gateway} dev ${nic_name}
%{ endif ~}
ExecStart=/usr/sbin/ip -4 route replace ${nic.cidr} dev ${nic_name} table ${nic.routing_table} src ${nic.ip_address}
ExecStart=/usr/sbin/ip -4 route replace default via ${nic.gateway} dev ${nic_name} table ${nic.routing_table} src ${nic.ip_address}
ExecStart=/usr/sbin/ip -4 rule add pref ${nic.routing_table} from ${nic.ip_address}/32 lookup ${nic.routing_table}
%{ endfor ~}
[Install]
WantedBy=multi-user.target
