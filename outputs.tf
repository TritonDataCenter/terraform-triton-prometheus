#
# Outputs
#
output "prometheus_ip" {
  value = ["${triton_machine.prometheus.*.primaryip}"]
}

output "prometheus_role_tag" {
  value = "${var.role_tag}"
}

output "prometheus_cns_service_name" {
  value = "${var.cns_service_name}"
}
