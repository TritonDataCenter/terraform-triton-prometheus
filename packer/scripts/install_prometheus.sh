#!/bin/bash
#
# Installs Prometheus, configured with Triton Container Monitor.
#
# Note: Generally follows guidelines at https://web.archive.org/web/20170701145736/https://google.github.io/styleguide/shell.xml.
#

set -e

# check_prerequisites - exits if distro is not supported.
#
# Parameters:
#     None.
function check_prerequisites() {
  local distro
  if [[ -f "/etc/lsb-release" ]]; then
    distro="Ubuntu"
  fi

  if [[ -z "${distro}" ]]; then
    log "Unsupported platform. Exiting..."
    exit 1
  fi
}

# install_dependencies - installs dependencies
#
# Parameters:
#     $1: the name of the distribution.
function install_dependencies() {
  log "Updating package index..."
  apt-get -qq -y update
  log "Installing prerequisites..."
  apt-get -qq -y install wget
}

# check_arguments - returns 0 if prerequisites are satisfied or 1 if not.
#
# Parameters:
#     $1: the triton account name
#     $2: the prometheus version
#     $3: the cmon dns suffix
#     $4: the cmon endpoint
function check_arguments() {
  local -r triton_account=${1}
  local -r prometheus_version=${2}
  local -r cmon_dns_suffix=${3}
  local -r cmon_endpoint=${4}

  if [[ -z "${triton_account}" ]]; then
    log "Triton account name not provided. Exiting..."
    exit 1
  fi

  if [[ -z "${prometheus_version}" ]]; then
    log "Prometheus version not provided. Exiting..."
    exit 1
  fi

  if [[ -z "${cmon_dns_suffix}" ]]; then
    log "CMON DNS Suffix not provided. Exiting..."
    exit 1
  fi

  if [[ -z "${cmon_endpoint}" ]]; then
    log "CMON Endpoint not provided. Exiting..."
    exit 1
  fi
}

# install_prometheus - downloads and installs the specified tool and version
#
# Parameters:
#     $1: the triton account name
#     $2: the prometheus version
#     $3: the cmon dns suffix
#     $4: the cmon endpoint
function install_prometheus() {
  local -r triton_account=${1}
  local -r prometheus_version=${2}
  local -r cmon_dns_suffix=${3}
  local -r cmon_endpoint=${4}

  local -r path_file="prometheus-${prometheus_version}.linux-amd64.tar.gz"
  local -r path_install="/usr/local/prometheus-${prometheus_version}.linux-amd64"

  log "Downloading prometheus ${prometheus_version}..."
  wget -q https://github.com/prometheus/prometheus/releases/download/v${prometheus_version}/${path_file} -O ${path_file}

  log "Installing prometheus ${prometheus_version}..."

  useradd prometheus

  install -d -o prometheus -g prometheus ${path_install}
  tar -xzf ${path_file} -C /usr/local/

  install -d -o prometheus -g prometheus /var/lib/prometheus/
  install -d -o prometheus -g prometheus /etc/prometheus/
  install -d -o prometheus -g prometheus /etc/prometheus/triton_certs/

  /usr/bin/printf "
global:
# all defaults

scrape_configs:
  - job_name: triton_cmon
    scrape_interval: 15s
    scrape_timeout: 5s
    scheme: https
    tls_config:
      cert_file: /etc/prometheus/triton_certs/cert.pem
      key_file: /etc/prometheus/triton_certs/key.pem
      insecure_skip_verify: true
    triton_sd_configs:
      - account: ${triton_account}
        dns_suffix: ${cmon_dns_suffix}
        endpoint: ${cmon_endpoint}
        version: 1
        tls_config:
          cert_file: /etc/prometheus/triton_certs/cert.pem
          key_file: /etc/prometheus/triton_certs/key.pem
          insecure_skip_verify: true\n" \
  > /etc/prometheus/prometheus.yml

    /usr/bin/printf "
[Unit]
Description=Prometheus Server
Documentation=https://prometheus.io/docs/introduction/overview/
After=network-online.target

[Service]
User=prometheus
Restart=on-failure
ExecStart=${path_install}/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/var/lib/prometheus/

[Install]
WantedBy=default.target\n" \
  > /etc/systemd/system/prometheus.service

  log "Installing triton-cmon certificates..."
  install -o prometheus -g prometheus /tmp/prometheus_installer/cert.pem /etc/prometheus/triton_certs/cert.pem
  install -o prometheus -g prometheus /tmp/prometheus_installer/key.pem /etc/prometheus/triton_certs/key.pem

  log "Starting prometheus..."
  systemctl daemon-reload

  systemctl enable prometheus.service
  systemctl start prometheus.service
}

# info - prints an informational message
#
# Parameters:
#     $1: the message
function log() {
  local -r message=${1}
  local -r script_name=$(basename ${0})
  echo -e "==> ${script_name}: ${message}"
}

# main
function main() {
  check_prerequisites

  local -r arg_triton_account_uuid=$(mdata-get 'sdc:owner_uuid') # see https://eng.joyent.com/mdata/datadict.html
  local -r arg_prometheus_version=$(mdata-get 'prometheus_version')
  local -r arg_cmon_dns_suffix=$(mdata-get 'cmon_dns_suffix')
  local -r arg_cmon_endpoint=$(mdata-get 'cmon_endpoint')

  check_arguments \
    ${arg_triton_account_uuid} ${arg_prometheus_version} ${arg_cmon_dns_suffix} ${arg_cmon_endpoint}

  install_dependencies
  install_prometheus \
    ${arg_triton_account_uuid} ${arg_prometheus_version} ${arg_cmon_dns_suffix} ${arg_cmon_endpoint}

  log "Done."
}

main
