#!/bin/bash

set -euo pipefail

WORKDIR=$(mktemp -d)
RANCHER_VERSION="$1"

pushd "${WORKDIR}"

# Download the manifest with a full images list
hauler store add image "rgcrprod.azurecr.us/hauler/rancher-manifest.yaml:v${RANCHER_VERSION}"
hauler store extract "rgcrprod.azurecr.us/hauler/rancher-manifest.yaml:v${RANCHER_VERSION}"

# Extract into plain text image reference per line
yq '.spec.images[] | select(.name)' "rancher-manifest.yaml" | awk '{print $2}' > "orig-rancher-images.txt"

# Filter out unwanted images
sed -E '/aks|ali|aws|azureserviceoperator|eks|gke|mirrored|nginx|redis|thanos/d' \
  "orig-rancher-images.txt" \
  > "filtered-rancher-images.txt"

# Re-add Cluster API and pause
grep cluster-api "orig-rancher-images.txt" >> "filtered-rancher-images.txt"
grep pause "orig-rancher-images.txt" >> "filtered-rancher-images.txt"
grep mirrored-kube-vip "orig-rancher-images.txt" >> "filtered-rancher-images.txt"
grep mirrored-longhorn "orig-rancher-images.txt" >> "filtered-rancher-images.txt"

# Pick the latest tag for each repo ———
> "unsorted-rancher.txt"
awk -F: '{print $1}' "filtered-rancher-images.txt" | sort -u |
while read -r repo; do
  grep -w "$repo" "filtered-rancher-images.txt" \
    | sort -Vr | head -1 \
    >> "unsorted-rancher.txt"
done

# Final sort & dedupe
sort -u "unsorted-rancher.txt" > "rancher-images.txt"

popd

cat <<EOF > rancher-manifest.yaml
apiVersion: content.hauler.cattle.io/v1
kind: Images
metadata:
  name: carbide-rancher-images
spec:
  images:
EOF

while read -r img; do
  echo "    - name: ${img}"
done < "${WORKDIR}/rancher-images.txt" >> rancher-manifest.yaml

rm -r "${WORKDIR}"
