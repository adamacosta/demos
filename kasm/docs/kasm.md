# Kasm Installation

## Create CA infrastructure

Install `cert-manager`:

```sh
kubectl apply -f manifests/cert-manager.yaml
```

Create the CA `ClusterIssuer`:

```sh
kubectl apply -k manifests/
kubectl wait \
  --for=condition=Ready \
  --timeout=30s \
  clusterissuer/ca-issuer
```

## Kasm Workspaces

Install `kasm`:

```sh
kubectl apply -f manifests/kasm.yaml
```

The log will print the notes from the Helm chart saying how to login:

```txt
To log into your Kasm deployment use the information below:

Kasm URL:                                   https://kasm.localdomain
External Agent Kasm Upstream Auth Address:  https://kasm.localdomain
KubeVirt Kasm Upstream Auth Address:        kasm-proxy.kasm-system.svc.cluster.local
Kasm Admin User:                            admin@kasm.local
Kasm Un-privileged User:                    user@kasm.local


Retrieve Kasm Admin Password:
kubectl get secret --namespace kasm-system kasm-secrets -o jsonpath="{.data.admin-password}" | base64 -d

Retrieve Kasm User Password:
kubectl get secret --namespace kasm-system kasm-secrets -o jsonpath="{.data.user-password}" | base64 -d


If you would like to get the remaining password values to store in a secure vault for future use.
If you update or upgrade your deployment using this Helm chart, these values will be reused

Retrieve Kasm DB Password:
kubectl get secret --namespace kasm-system kasm-secrets -o jsonpath="{.data.db-password}" | base64 -d

Retrieve Kasm Manager Token:
kubectl get secret --namespace kasm-system kasm-secrets -o jsonpath="{.data.manager-token}" | base64 -d

Retrieve Kasm Service Registration Token:
kubectl get secret --namespace kasm-system kasm-secrets -o jsonpath="{.data.service-token}" | base64 -d
```
