%{if length(additional_vdisks) > 0 ~}
#!/bin/bash
set -euo pipefail
%{ for vdisk_name, vdisk in additional_vdisks ~}
parted -s "${vdisk.path}" mklabel gpt
parted -s "${vdisk.path}" mkpart primary 1MiB 100%
partprobe "${vdisk.path}"
udevadm settle
pvcreate -ff -y "${vdisk.path}1"
vgcreate "vg_${vdisk_name}" "${vdisk.path}1"
vgchange -ay "vg_${vdisk_name}"
%{ endfor ~}
mkdir -p "/backups"
%{ for vdisk_name, vdisk in additional_vdisks ~}
%{ for partition_name, partition in vdisk.partitions ~}
lvcreate -y -L "${partition.size}G" -n "lv_${partition_name}" "vg_${vdisk_name}"
%{ if partition.fstype == "ext4" ~}
mkfs.ext4 -F "/dev/vg_${vdisk_name}/lv_${partition_name}"
echo "/dev/vg_${vdisk_name}/lv_${partition_name} ${partition.mount_target} ext4 ${partition.mount_options} 0 2" >> /etc/fstab
%{ endif ~}
%{ if partition.fstype == "xfs" ~}
mkfs.xfs -f "/dev/vg_${vdisk_name}/lv_${partition_name}"
echo "/dev/vg_${vdisk_name}/lv_${partition_name} ${partition.mount_target} xfs ${partition.mount_options} 0 0" >> /etc/fstab
%{ endif ~}
mkdir -p "${partition.mount_target}"
rsync -aAXH --numeric-ids "${partition.mount_target}/" "/backups${partition.mount_target}/"
mount "/dev/vg_${vdisk_name}/lv_${partition_name}" "${partition.mount_target}"
rsync -aAXH --numeric-ids "/backups${partition.mount_target}/" "${partition.mount_target}/"
%{ endfor ~}
%{ endfor ~}
rm -rf /backups
%{ endif ~}
