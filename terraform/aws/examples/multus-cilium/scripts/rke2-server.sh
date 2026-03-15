#!/bin/sh

set -xeo pipefail

TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
PRIVATE_IP=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/local-ipv4)
PUBLIC_IP=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-ipv4)

cat <<EOF >> /etc/rancher/rke2/config.yaml
tls-san:
  - ${PUBLIC_IP}
EOF

# add private IP to reach API server
cat <<EOF >> /var/lib/rancher/rke2/server/manifests/rke2-cilium-config.yaml
    k8sServiceHost: "$PRIVATE_IP"
EOF

curl -fsLS https://get.rke2.io | INSTALL_RKE2_CHANNEL=stable INSTALL_RKE2_TYPE=server sh -

systemctl restart systemd-sysctl
systemctl enable --now rke2-server

# wait for rke2 to be up - won't take 10 minutes, but being safe
timeout 10m bash -c 'until [ -f /etc/rancher/rke2/rke2.yaml ]; do sleep 1; done'

mkdir /home/ec2-user/.kube
cp /etc/rancher/rke2/rke2.yaml /home/ec2-user/.kube/config
chown ec2-user:ec2-user /home/ec2-user/.kube/config

cat <<EOF >> /home/ec2-user/.bashrc
export PATH="$PATH:/var/lib/rancher/rke2/bin"
EOF
