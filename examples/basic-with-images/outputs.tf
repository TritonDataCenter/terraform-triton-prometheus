#
# Outputs
#
output "bastion_address" {
  value = "${module.bastion.bastion_address}"
}

output "prometheus_address" {
  value = "${module.prometheus.prometheus_address}"
}
