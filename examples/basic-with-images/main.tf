#
# Terraform/Providers
#
terraform {
  required_version = ">= 0.11.0"
}

provider "triton" {
  version = ">= 0.4.1"
}

#
# Remote State
#
terraform {
  backend "manta" {
    path       = "terraform-state/prometheus/"
    objectName = "terraform.tfstate"
  }
}

#
# Data Sources
#
data "triton_image" "ubuntu" {
  name        = "ubuntu-16.04"
  type        = "lx-dataset"
  most_recent = true
}

data "triton_image" "prometheus" {
  name        = "prometheus"
  type        = "lx-dataset"
  most_recent = true
}

data "triton_network" "public" {
  name = "Joyent-SDC-Public"
}

data "triton_network" "private" {
  name = "My-Fabric-Network"
}

#
# Modules
#
module "bastion" {
  source = "github.com/joyent/terraform-triton-bastion"

  name    = "prometheus-basic-with-images"
  image   = "${data.triton_image.ubuntu.id}" # note: using the UBUNTU image here
  package = "g4-general-4G"

  # Public and Private
  networks = [
    "${data.triton_network.public.id}",
    "${data.triton_network.private.id}",
  ]
}

module "prometheus" {
  source = "../../"

  name    = "prometheus-basic-with-images"
  image   = "${data.triton_image.prometheus.id}" # note: using the PROMETHEUS image here
  package = "g4-general-4G"

  # Private
  networks = [
    "${data.triton_network.private.id}",
  ]

  provision        = "false"                   # note: we are NOT provisioning as we ARE using pre-built images
  private_key_path = "${var.private_key_path}"

  cmon_cert_file_path = "" # note: unused since we're using pre-built images
  cmon_key_file_path  = "" # note: unused since we're using pre-built images

  bastion_address          = "${module.bastion.bastion_address}"
  bastion_user             = "${module.bastion.bastion_user}"
  bastion_cns_service_name = "${module.bastion.bastion_cns_service_name}"
}
