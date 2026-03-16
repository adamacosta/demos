# Kasm Docker Agent

The agent is simply another VM. We put it in its own namespace `kasm-agent` separate from the `kasm` namespace that houses the guest cluster. The VM is created using the same Terraform module that creates the guest cluster for the workspaces installation.

First, grab the manager token from the Kasm workspaces server:

```sh
kubectl get secret --namespace kasm-system kasm-secrets -o jsonpath="{.data.manager-token}" | base64 -d
```

Once the VM to host the agent is running, ssh into it and run:

```sh
MANAGER_TOKEN="${VALUE_FROM_ABOVE}$"
sudo bash /tmp/kasm_release/install.sh \
  --role agent \
  --offline-workspaces /tmp/kasm_release_workspace_images_amd64_1.18.1.tar.gz \
  --offline-service /tmp/kasm_release_service_images_amd64_1.18.1.tar.gz \
  --offline-network-plugin /tmp/kasm_release_network_plugin_images_amd64_1.18.1.tar.gz \
  --offline-logger-plugin /tmp/kasm_release_logging_plugin_images_amd64_1.18.1.tar.gz \
  --public-hostname kasm-agent-0.localdomain \
  --manager-hostname kasm.localdomain \
  --manager-token $MANAGER_TOKEN
```
