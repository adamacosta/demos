#!/bin/sh

set -xeo pipefail

curl -fsLS https://get.rke2.io | INSTALL_RKE2_CHANNEL=stable INSTALL_RKE2_TYPE=agent sh -

systemctl restart systemd-sysctl
systemctl enable rke2-agent
