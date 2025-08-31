# homelab-terraform
A Terraform module to provision VMs on PVE (Proxmox Virtual Environment) nodes using bpg provider.\
This project was tested on a single PVE node running version 9.0.\
Due to the limitations of the current state of the API, and my desire to support CPU affinity, root@pam is required.

## Objective(s)
- Provision VMs using JSON payload(s) consisting of VM "templates" instead of individual VMs.
___
## Requirements
- **API Token** for the root user
- SSH access to PVE nodes using **root@pam**
- **Snippets** and **Import** content enabled in Proxmox Storage
___
## Instructions
1. Setup SSH on the PVE nodes and SSH agent on the Terraform execution node (or edit providers.tf to use password instead)
2. Referencing **sample.tfvars.json** and **variables.tf**, create the payload to provision desired VMs.
3. Terraform apply
___
## License
homelab-terraform is licensed under the MIT license, see [LICENSE](LICENSE) for details.
