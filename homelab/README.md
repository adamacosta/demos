# Harvester Homelab Demo

## Actions in Harvester

### Create a VM network

```sh
kubectl create -f manifests/network.yaml
```

### Create VM image for root volume

```sh
kubectl create -f manifests/image.yaml
kubectl wait --for=condition=Imported \
  --namespace harvester-public \
  --timeout=300s \
  virtualmachineimages/opensuse-leap-15-6
```

### Create demo namespace

```sh
kubectl create -f manifests/namespace.yaml
```

### Create a standalone VM

```sh
kubectl create -f manifests/vm.yaml
```
