#!/bin/sh

set -xeo pipefail

# EPEL rpm dynamically generates .repo files, so don't try to use cloud-init yumaddrepo
dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm
dnf install -y bat neovim

TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
PRIVATE_IP=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/local-ipv4)
PUBLIC_IP=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-ipv4)

cat <<EOF >> /etc/rancher/rke2/config.yaml
tls-san:
  - ${PUBLIC_IP}
EOF

cat <<EOF >> /root/.bashrc
export PATH="$PATH:/var/lib/rancher/rke2/bin"
export KUBECONFIG="/etc/rancher/rke2/rke2.yaml"
export CRI_CONFIG_FILE="/var/lib/rancher/rke2/agent/etc/crictl.yaml"
export CONTAINERD_ADDRESS="/run/k3s/containerd/containerd.sock"
EOF

# ancillary tools - yq, calicoctl, helm
curl -fsLS https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 \
  -o /usr/local/bin/yq &&\
  chmod 0755 /usr/local/bin/yq

curl -fsLS https://github.com/projectcalico/calico/releases/latest/download/calicoctl-linux-amd64 \
  -o /usr/local/bin/calicoctl &&\
  chmod 0755 /usr/local/bin/calicoctl

curl -fsLS https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4 | bash

curl -fsLS https://get.rke2.io | INSTALL_RKE2_CHANNEL=stable sh -

systemctl restart systemd-sysctl
systemctl -q is-enabled nm-cloud-setup.service && systemctl disable nm-cloud-setup.service
systemctl -q is-enabled nm-cloud-setup.timer && systemctl disable nm-cloud-setup.timer

# calico in kube-proxy replacement mode needs externally routable address for API server
# because it cannot rely on the service being created by kube-proxy
# using private IP to keep traffic in VPC and because going outside will lose
# the security group tag and block traffic without allowing AWS's NAT device egress blocks
cat <<EOF > /var/lib/rancher/rke2/server/manifests/kubernetes-service-endpoint.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  creationTimestamp: null
  name: kubernetes-services-endpoint
  namespace: tigera-operator
data:
  KUBERNETES_SERVICE_HOST: "$PRIVATE_IP"
  KUBERNETES_SERVICE_PORT: "6443"
EOF

systemctl enable --now rke2-server

# wait for rke2 to be up - won't take 10 minutes, but being safe
timeout 10m bash -c 'until [ -f /etc/rancher/rke2/rke2.yaml ]; do sleep 1; done'

mkdir /home/ec2-user/.kube
cp /etc/rancher/rke2/rke2.yaml /home/ec2-user/.kube/config
chown ec2-user:ec2-user /home/ec2-user/.kube/config

cat <<EOF >> /home/ec2-user/.bashrc
export PATH="$PATH:/var/lib/rancher/rke2/bin"
EOF
