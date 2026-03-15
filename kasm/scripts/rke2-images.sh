#!/bin/bash

set -euo pipefail

WORKDIR=$(mktemp -d)
RKE2_VERSION="$1"

pushd "${WORKDIR}"

curl -fsLSO "https://github.com/rancher/rke2/releases/download/${RKE2_VERSION}/rke2-images-core.linux-amd64.txt"
curl -fsLSO "https://github.com/rancher/rke2/releases/download/${RKE2_VERSION}/rke2-images-cilium.linux-amd64.txt"
curl -fsLSO "https://github.com/rancher/rke2/releases/download/${RKE2_VERSION}/rke2-images-harvester.linux-amd64.txt"

cat rke2-images-*.txt | sed -E '/aws|azure|nginx/d' | sed 's/docker\.io/registry\.ranchercarbide\.dev/g' \
  > rke2-images.txt

popd

cat <<EOF > rke2-manifest.yaml
apiVersion: content.hauler.cattle.io/v1
kind: Images
metadata:
  name: carbide-rke2-images
spec:
  images:
EOF

while read -r img; do
  echo "    - name: ${img}"
done < "${WORKDIR}/rke2-images.txt" >> rke2-manifest.yaml

rm -r "${WORKDIR}"
