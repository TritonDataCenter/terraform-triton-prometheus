resource "null_resource" "prometheus_install" {
  count = "${var.provision == "true" ? "1" : 0}"

  triggers {
    machine_ids = "${triton_machine.prometheus.*.id[count.index]}"
  }

  connection {
    bastion_host        = "${var.bastion_host}"
    bastion_user        = "${var.bastion_user}"
    bastion_private_key = "${file(var.private_key_path)}"

    host        = "${triton_machine.prometheus.*.primaryip[count.index]}"
    user        = "${var.user}"
    private_key = "${file(var.private_key_path)}"
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /tmp/prometheus_installer/",
    ]
  }

  provisioner "file" {
    source      = "${path.module}/packer/scripts/install_prometheus.sh"
    destination = "/tmp/prometheus_installer/install_prometheus.sh"
  }

  provisioner "file" {
    source      = "${var.cmon_cert_file_path}"
    destination = "/tmp/prometheus_installer/cert.pem"
  }

  provisioner "file" {
    source      = "${var.cmon_key_file_path}"
    destination = "/tmp/prometheus_installer/key.pem"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 0755 /tmp/prometheus_installer/install_prometheus.sh",
      "sudo /tmp/prometheus_installer/install_prometheus.sh",
    ]
  }

  # clean up
  provisioner "remote-exec" {
    inline = [
      "rm -rf /tmp/prometheus_installer/",
    ]
  }
}
