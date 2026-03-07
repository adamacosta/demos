#!/bin/sh

install_awscli() {
  # Whole lotta rigamarole because SL Micro doesn't provide tooling, AWS doesn't provide
  # a UNIX-friendly archive format, and the root filesystem is immutable
  WORKDIR=$(mktemp -d)
  pushd "$WORKDIR"
  curl -fsLS "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" \
    -o awscliv2.zip
  curl -fsLS "https://download.opensuse.org/distribution/leap/15.6/repo/oss/x86_64/unzip-6.00-150000.4.11.1.x86_64.rpm" \
    -o unzip.rpm
  rpm2cpio unzip.rpm | cpio -di
  ./usr/bin/unzip-plain awscliv2.zip
  # By default, this installs to /usr/local/aws and links bins to /usr/local/bin,
  # which is fine because /usr/local is mounted rw
  ./aws/install --update
  popd
  rm -rf "$WORKDIR"
}

install_hauler() {
  # Will default to /usr/local/bin/hauler
  curl -fsLS https://get.hauler.dev | bash -
}

hauler_login() {
  USERNAME="$1"
  TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
  REGION=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/region)
  ACCOUNT_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/identity-credentials/ec2/info |
    jq -r '.AccountId')
  PASSWORD=$(aws secretsmanager get-secret-value \
    --secret-id "arn:aws:secretsmanager:$${REGION}:$${ACCOUNT_ID}:secret:rgcrprod.azurecr.us/$USERNAME" | 
    jq -r '.SecretString' | 
    jq -r '.carbide_password')
  hauler login -u $USERNAME -p $PASSWORD rgcrprod.azurecr.us
}

hauler_save_images() {
  hauler store sync --products rke2="$1" --platform linux/amd64
  hauler store save --filename rke2-"$1"-images.tar.zst
  mkdir -p /var/lib/rancher/rke2/agent/images
  mv -f rke2-"$1"-images.tar.zst /var/lib/rancher/rke2/agent/images/
}

{
  install_awscli
  install_hauler
  hauler_login ${carbide_user}
  hauler_save_images $(curl -fsLS https://update.rke2.io/v1-release/channels | jq -r '.data[] | select(.id=="stable").latest')
}
