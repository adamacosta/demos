#!/bin/sh

set -xeo pipefail

# EPEL rpm dynamically generates .repo files, so don't try to use cloud-init yumaddrepo
dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm
dnf install -y bat neovim

cat <<EOF >> /root/.bashrc
alias claer='clear'
alias clar='clear'
alias cler='clear'
alias clrea='clear'
alias clrae='clear'
alias clera='clear'
alias clare='clear'
export PATH="$PATH:/var/lib/rancher/rke2/bin"
export KUBECONFIG="/etc/rancher/rke2/rke2.yaml"
export CRI_CONFIG_FILE="/var/lib/rancher/rke2/agent/etc/crictl.yaml"
export CONTAINERD_ADDRESS="/run/k3s/containerd/containerd.sock"
command -v kubectl >/dev/null && . <(kubectl completion bash)
EOF

cat <<EOF >> /home/ec2-user/.bashrc
alias claer='clear'
alias clar='clear'
alias cler='clear'
alias clrea='clear'
alias clrae='clear'
alias clera='clear'
alias clare='clear'
export PATH="$PATH:/var/lib/rancher/rke2/bin"
command -v kubectl >/dev/null && . <(kubectl completion bash)
EOF

# ancillary tools - aws cli, yq, helm, cilium, hubble
curl -fsLS https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip \
  -o awscliv2.zip &&
unzip awscliv2.zip &&
./aws/install &&
rm -rf aws*

curl -fsLS https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 \
  -o /usr/local/bin/yq &&
  chmod +x /usr/local/bin/yq

curl -fsLS https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4 | bash

curl -fsLS https://github.com/cilium/cilium-cli/releases/latest/download/cilium-linux-amd64.tar.gz |
  tar -C /usr/local/bin -vxz

curl -fsLS https://github.com/cilium/hubble/releases/latest/download/hubble-linux-amd64.tar.gz |
  tar -C /usr/local/bin -vxz

systemctl -q is-enabled nm-cloud-setup.service && systemctl disable nm-cloud-setup.service
systemctl -q is-enabled nm-cloud-setup.timer && systemctl disable nm-cloud-setup.timer
systemctl restart systemd-sysctl