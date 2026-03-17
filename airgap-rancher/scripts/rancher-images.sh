#!/bin/bash

set -euo pipefail

WORKDIR=$(mktemp -d)
RANCHER_VERSION="$1"

pushd "${WORKDIR}"

# Download the manifest with a full images list
hauler store add image "registry.ranchercarbide.dev/hauler/rancher-manifest.yaml:v${RANCHER_VERSION}"
hauler store extract "registry.ranchercarbide.dev/hauler/rancher-manifest.yaml:v${RANCHER_VERSION}"

# Extract into plain text image reference per line
yq '.spec.images[] | select(.name)' "rancher-manifest.yaml" | awk '{print $2}' > "orig-rancher-images.txt"

# Filter out unwanted images
sed -E '/aks|ali|aws|azureserviceoperator|eks|gke|mirrored|nginx|redis|thanos/d' \
  "orig-rancher-images.txt" \
  > "filtered-rancher-images.txt"

# Needed:
# - cluster-api is now used by all provisioners
# - pause required by runtime
# - kube-vip and longhorn needed for harvester clusters
# - sonobuoy is the scanner used by compliance-operator
grep cluster-api "orig-rancher-images.txt" >> "filtered-rancher-images.txt"
grep pause "orig-rancher-images.txt" >> "filtered-rancher-images.txt"
grep mirrored-kube-vip "orig-rancher-images.txt" >> "filtered-rancher-images.txt"
grep mirrored-longhorn "orig-rancher-images.txt" >> "filtered-rancher-images.txt"
grep mirrored-sonobuoy "orig-rancher-images.txt" >> "filtered-rancher-images.txt"

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
