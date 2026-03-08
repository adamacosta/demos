#!/bin/bash

PARENT=`dirname "$0"`
CONFIG_DIR="$PARENT/../files"
MANIFEST_DIR="$PARENT/../manifests"

[ -z "$1" ] || CONFIG_DIR="$1"
[ -z "$2" ] || MANIFEST_DIR="$2"

AUDIT_POLICY_B64=$(base64 -w 0 < "$CONFIG_DIR/audit-policy.yaml")
RKE2_CONFIG_B64=$(base64 -w 0 < "$CONFIG_DIR/config.yaml")
RANCHER_PSS_B64=$(base64 -w 0 < "$CONFIG_DIR/rancher-pss.yaml")
REGISTRIES_B64=$(base64 -w 0 < "$CONFIG_DIR/registries.yaml")
CLOUD_PROVIDER_CONFIG_B64=$(base64 -w 0 < "$MANIFEST_DIR/harvester-cloud-provider-config.yaml")
CILIUM_CONFIG_B64=$(base64 -w 0 < "$MANIFEST_DIR/rke2-cilium-config.yaml")
TRAEFIK_CONFIG_B64=$(base64 -w 0 < "$MANIFEST_DIR/rke2-traefik-config.yaml")
cat <<EOF
write_files:
  - encoding: b64
    content: $AUDIT_POLICY_B64
    path: /etc/rancher/rke2/audit-policy.yaml
  - encoding: b64
    content: $RKE2_CONFIG_B64
    path: /etc/rancher/rke2/config.yaml
  - encoding: b64
    content: $RANCHER_PSS_B64
    path: /etc/rancher/rke2/rancher-pss.yaml
  - encoding: b64
    content: $REGISTRIES_B64
    path: /etc/rancher/rke2/registries.yaml
  - encoding: b64
    content: $CLOUD_PROVIDER_CONFIG_B64
    path: /var/lib/rancher/rke2/server/manifests/harvester-cloud-provider-config.yaml
  - encoding: b64
    content: $CILIUM_CONFIG_B64
    path: /var/lib/rancher/rke2/server/manifests/rke2-cilium-config.yaml
  - encoding: b64
    content: $TRAEFIK_CONFIG_B64
    path: /var/lib/rancher/rke2/server/manifests/rke2-traefik-config.yaml
EOF
