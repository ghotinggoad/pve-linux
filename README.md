# pve-linux
A Terraform module to provision Linux VMs on PVE (Proxmox Virtual Environment) nodes using bpg provider.\
This project was tested on a single PVE node running version 9.1.\

## Feature(s)
- Simultaneously provision VMs with different functions and specifications using JSON payload(s) consisting of VM Replica "templates"
- Guest VMs support multiple NICs, distro-agnostic PBR (Policy-Based Routing) using systemd service.
- Additional partitions created using LVM (Logical Volume Manager) for future expansion.
___
## Limitation(s)
- root@pam is required on PVE due to the limitations of the current state of the API and my desire to support CPU affinity.
- Limited to Linux Distros with systemd due to PBR implementation.
- Additional partitions require storage overhead from usage of LVM.
- Existing directories will be migrated but residual files (e.g. /var) are NOT deleted.
___
## Requirement(s)
- **CHECK LIMITATION(S)**
- **API Token** for the root user
- SSH access to PVE nodes using **root@pam**
- **Snippets** and **Import** content enabled in Proxmox Storage
___
## Instruction(s)
1. Setup SSH on the PVE nodes and SSH agent on the Terraform execution node (or edit providers.tf to use password instead)
2. Referencing **sample.tfvars.json** and **variables.tf**, create the payload to provision desired VMs.
3. Terraform apply
___
## License
pve-linux is licensed under the MIT license, see [LICENSE](LICENSE) for details.
