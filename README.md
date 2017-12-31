# Triton TODO Terraform Module

A Terraform module to create a [Prometheus server](https://prometheus.io/) for 
[Joyent's Triton Compute service](https://www.joyent.com/triton/compute), integrated with Container Monitor service 
for monitoring machine and container metrics.

## Usage

```hcl
data "triton_image" "ubuntu" {
  name        = "ubuntu-16.04"
  type        = "lx-dataset"
  most_recent = true
}

data "triton_network" "public" {
  name = "Joyent-SDC-Public"
}

data "triton_network" "private" {
  name = "My-Fabric-Network"
}

module "bastion" {
  source = "github.com/joyent/terraform-triton-bastion"

  name    = "basic-with-provisioning"
  image   = "${data.triton_image.ubuntu.id}"
  package = "g4-general-4G"

  # Public and Private
  networks = [
    "${data.triton_network.public.id}",
    "${data.triton_network.private.id}",
  ]
}

module "prometheus" {
  source = "../../"

  name    = "basic-with-provisioning"
  image   = "${data.triton_image.ubuntu.id}"
  package = "g4-general-4G"

  networks = [
    "${data.triton_network.private.id}",
  ]

  provision        = "true"
  private_key_path = "${var.private_key_path}"

  cmon_cert_file_path = "${var.prometheus_cmon_cert_file_path}"
  cmon_key_file_path  = "${var.prometheus_cmon_key_file_path}"

  bastion_host     = "${element(module.bastion.bastion_ip,0)}"
  bastion_user     = "${module.bastion.bastion_user}"
  bastion_role_tag = "${module.bastion.bastion_role_tag}"
}
```

## Examples
- [basic-with-images](examples/basic-with-images) - Deploys a Prometheus server and relevant resources. Prometheus 
server will be deployed from _pre-existing_ images, ideally built by Packer.
- [basic-with-provisioning](examples/basic-with-provisioning) - Deploys a Prometheus server and relevant resources. 
Prometheus server will be _provisioned_ by Terraform.

## Resources created

- [`triton_machine.prometheus`](https://www.terraform.io/docs/providers/triton/r/triton_machine.html): The Prometheus 
machine.
- [`triton_firewall_rule.ssh`](https://www.terraform.io/docs/providers/triton/r/triton_firewall_rule.html): The firewall
rule(s) allowing SSH access FROM the bastion machine(s) TO the Prometheus machine.
- [`triton_firewall_rule.web_access`](https://www.terraform.io/docs/providers/triton/r/triton_firewall_rule.html): The 
firewall rule(s) allowing access FROM client machines or addresses TO Prometheus web ports.
