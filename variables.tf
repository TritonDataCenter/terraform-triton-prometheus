#
# Variables
#
variable "name" {
  description = "The name of the environment."
  type        = "string"
}

variable "image" {
  description = "The image to deploy as the Prometheus machine(s)."
  type        = "string"
}

variable "package" {
  description = "The package to deploy as the Prometheus machine(s)."
  type        = "string"
}

variable "networks" {
  description = "The networks to deploy the Prometheus machine(s) within."
  type        = "list"
}

variable "private_key_path" {
  description = "The path to the private key to use for provisioning machines."
  type        = "string"
}

variable "user" {
  description = "The user to use for provisioning machines."
  type        = "string"
  default     = "root"
}

variable "provision" {
  description = "Boolean 'switch' to indicate if Terraform should do the machine provisioning to install and configure Prometheus."
  type        = "string"
}

variable "version" {
  description = "The version of Prometheus to install. See https://prometheus.io/download/."
  default     = "2.2.1"                                                                      # Note: Be sure to change this in the Packer script too.
  type        = "string"
}

variable "cns_service_name" {
  description = "The Prometheus CNS service name. Note: this is the service name only, not the full CNS record."
  type        = "string"
  default     = "prometheus"
}

variable "cmon_dns_suffix" {
  description = "The full DNS suffix to use for configuring Prometheus. If omitted, will use default pattern for Joyent Public Cloud."
  type        = "string"
  default     = ""
}

variable "cmon_endpoint" {
  description = "The full address to use for configuring Prometheus. If omitted, will use default pattern for Joyent Public Cloud."
  type        = "string"
  default     = ""
}

variable "cmon_fqdn_base" {
  description = "The fully qualified domain name base for the CNS address - e.g. 'triton.zone' for Joyent Public Cloud."
  type        = "string"
  default     = "triton.zone"
}

variable "cns_fqdn_base" {
  description = "The fully qualified domain name base for the CNS address - e.g. 'cns.joyent.com' for Joyent Public Cloud."
  type        = "string"
  default     = "cns.joyent.com"
}

variable "cmon_cert_file_path" {
  description = <<EOF
The path to the TLS certificate to use for authentication to the CMON endpoint.
The sdc-docker setup script is the easiest way to obtain this -
https://raw.githubusercontent.com/joyent/sdc-docker/master/tools/sdc-docker-setup.sh.
EOF

  type = "string"
}

variable "cmon_key_file_path" {
  description = <<EOF
The path to the TLS key to use for authentication to the CMON endpoint.
The sdc-docker setup script is the easiest way to obtain this -
https://raw.githubusercontent.com/joyent/sdc-docker/master/tools/sdc-docker-setup.sh.
EOF

  type = "string"
}

variable "client_access" {
  description = <<EOF
'From' targets to allow client access to Prometheus' web port - i.e. access from other VMs or public internet.
See https://docs.joyent.com/public-cloud/network/firewall/cloud-firewall-rules-reference#target
for target syntax.
EOF

  type    = "list"
  default = ["all vms"]
}

variable "bastion_address" {
  description = "The Bastion address to use for provisioning."
  type        = "string"
}

variable "bastion_user" {
  description = "The Bastion user to use for provisioning."
  type        = "string"
}

variable "bastion_cns_service_name" {
  description = "The CNS service name for the Prometheus machine(s) to allow access FROM the Bastion machine(s)."
  type        = "string"
}
