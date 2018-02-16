#
# Outputs
#
output "prometheus_primaryip" {
  value = ["${triton_machine.prometheus.*.primaryip}"]
}

output "prometheus_cns_service_name" {
  value = "${var.cns_service_name}"
}

output "prometheus_address" {
  value = "${local.prometheus_address}"
}
