#!/usr/bin/env bash
# Bash Script to install HashiCorp Nomad
# REF: https://learn.hashicorp.com/tutorials/nomad/production-deployment-guide-vm-with-consul?in=nomad/enterprise
set -e

export NOMAD_VERSION="1.1.0"
curl --silent --remote-name https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip
unzip nomad_${NOMAD_VERSION}_linux_amd64.zip
sudo chown root:root nomad
sudo mv nomad /usr/local/bin/
#nomad version

nomad -autocomplete-install
complete -C /usr/local/bin/nomad nomad
sudo mkdir --parents /opt/nomad
sudo useradd --system --home /etc/nomad.d --shell /bin/false nomad

sudo touch /etc/systemd/system/nomad.service
tee -a /etc/systemd/system/nomad.service <<EOF
[Unit]
Description=Nomad
Documentation=https://www.nomadproject.io/docs/
Wants=network-online.target
After=network-online.target

# When using Nomad with Consul it is not necessary to start Consul first. These
# lines start Consul before Nomad as an optimization to avoid Nomad logging
# that Consul is unavailable at startup.
#Wants=consul.service
#After=consul.service

[Service]

# Nomad server should be run as the nomad user. Nomad clients
# should be run as root
User=nomad
Group=nomad

ExecReload=/bin/kill -HUP $MAINPID
ExecStart=/usr/local/bin/nomad agent -config /etc/nomad.d
KillMode=process
KillSignal=SIGINT
LimitNOFILE=65536
LimitNPROC=infinity
Restart=on-failure
RestartSec=2

## Configure unit start rate limiting. Units which are started more than
## *burst* times within an *interval* time span are not permitted to start any
## more. Use `StartLimitIntervalSec` or `StartLimitInterval` (depending on
## systemd version) to configure the checking interval and `StartLimitBurst`
## to configure how many starts per interval are allowed. The values in the
## commented lines are defaults.

# StartLimitBurst = 5

## StartLimitIntervalSec is used for systemd versions >= 230
# StartLimitIntervalSec = 10s

## StartLimitInterval is used for systemd versions < 230
# StartLimitInterval = 10s

TasksMax=infinity
OOMScoreAdjust=-1000

[Install]
WantedBy=multi-user.target
EOF

# CONFIGURE NOMAD
sudo mkdir --parents /etc/nomad.d
sudo chmod 700 /etc/nomad.d
sudo touch /etc/nomad.d/nomad.hcl
tee -a /etc/nomad.d/nomad.hcl <<EOF
datacenter = "dc1"
data_dir = "/opt/nomad"
EOF
sudo touch /etc/nomad.d/server.hcl
tee -a /etc/nomad.d/server.hcl <<EOF
server {
  enabled = true
  bootstrap_expect = 3
}
EOF
sudo touch /etc/nomad.d/client.hcl
tee -a /etc/nomad.d/client.hcl <<EOF
client {
  enabled = true
}
EOF

sudo systemctl enable nomad
sudo systemctl start nomad
sudo systemctl status nomad