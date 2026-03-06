# Create single node Harvester cluster in Rancher using Terraform

Create an API key in the UI and then create a kubeconfig for the Harvester cloud provider:

```sh
RANCHER_SERVER_URL="https://rancher.localdomain"
RANCHER_ACCESS_KEY="token-d4lzc"
RANCHER_SECRET_KEY="csf7pvmgqlbw9m5qnf9ndwvg54zqmzkvghpxn6wrggs9qlghsztgkq"
HARVESTER_CLUSTER_ID="c-drkkh"
CLUSTER_NAME="single-node-leap"
curl -s -X POST ${RANCHER_SERVER_URL}/k8s/clusters/${HARVESTER_CLUSTER_ID}/v1/harvester/kubeconfig \
  -H 'Content-Type: application/json' \
  -u ${RANCHER_ACCESS_KEY}:${RANCHER_SECRET_KEY} \
  -d '{"clusterRoleName": "harvesterhci.io:cloudprovider", "namespace": "homelab-demo", "serviceAccountName": "'${CLUSTER_NAME}'"}' |
  tr -d '"' | 
  sed 's/\\n/\n/g' \
  > files/${CLUSTER_NAME}-kubeconfig
```

This API key will also be used for the provider config.
