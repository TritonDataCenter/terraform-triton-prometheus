#
# Outputs
#
output "bastion_ip" {
  value = ["${module.bastion.bastion_ip}"]
}

output "prometheus_ip" {
  value = ["${module.prometheus.prometheus_ip}"]
}

output "prometheus_address" {
  value = ["${module.prometheus.prometheus_address}"]
}
