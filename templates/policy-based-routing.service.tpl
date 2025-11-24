%{if length(nics) > 0 ~}
[Unit]
After=network-online.target
Wants=network-online.target
[Service]
Type=oneshot
Environment=PATH=/usr/sbin:/usr/bin:/sbin:/bin
%{ for nic_name, nic in nics ~}
%{ if nic.default ~}
ExecStart=ip -4 route replace default via ${nic.gateway} dev ${nic_name}
%{ endif ~}
ExecStart=ip -4 route replace default via ${nic.gateway} dev ${nic_name} table ${nic.routing_table}
ExecStart=ip -4 rule add pref ${nic.routing_table} from ${nic.ip_address}/32 lookup ${nic.routing_table}
%{ endfor ~}
[Install]
WantedBy=multi-user.target
%{ endif ~}
