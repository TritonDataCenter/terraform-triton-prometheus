#
# Outputs
#
output "prometheus_ip" {
  value = ["${module.prometheus.prometheus_ip}"]
}

output "bastion_ip" {
  value = ["${module.bastion.bastion_ip}"]
}
