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
# Data sources
#
data "triton_datacenter" "current" {}

data "triton_account" "current" {}

#
# Locals
#
locals {
  cmon_dns_suffix    = "cmon.${data.triton_datacenter.current.name}.${var.cmon_fqdn_base}"
  cmon_endpoint      = "cmon.${data.triton_datacenter.current.name}.${var.cmon_fqdn_base}"
  prometheus_address = "${var.role_tag}.svc.${data.triton_account.current.id}.${data.triton_datacenter.current.name}.${var.cns_fqdn_base}"
}

#
# Machines
#
resource "triton_machine" "prometheus" {
  name    = "${var.name}-prometheus"
  package = "${var.package}"
  image   = "${var.image}"

  firewall_enabled = true

  networks = ["${var.networks}"]

  tags {
    role = "${var.role_tag}"
  }

  cns {
    services = ["${var.cns_service_name}"]
  }

  metadata {
    prometheus_version = "${var.version}"
    cmon_dns_suffix    = "${var.cmon_dns_suffix != "" ? var.cmon_dns_suffix : local.cmon_dns_suffix}"
    cmon_endpoint      = "${var.cmon_endpoint != "" ? var.cmon_endpoint : local.cmon_endpoint}"
  }
}

#
# Firewall Rules
#
resource "triton_firewall_rule" "ssh" {
  rule        = "FROM tag \"role\" = \"${var.bastion_role_tag}\" TO tag \"role\" = \"${var.role_tag}\" ALLOW tcp PORT 22"
  enabled     = true
  description = "${var.name} - Allow access from bastion hosts to Prometheus servers."
}

resource "triton_firewall_rule" "web_access" {
  count = "${length(var.client_access)}"

  rule        = "FROM ${var.client_access[count.index]} TO tag \"role\" = \"${var.role_tag}\" ALLOW tcp PORT 9090"
  enabled     = true
  description = "${var.name} - Allow access from clients to Prometheus servers."
}
