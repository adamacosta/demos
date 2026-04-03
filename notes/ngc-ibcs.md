# NGC IBCS (Huntsville)

Trying to run KASM on Harvester.

cade thomas senior engineer advocate for harvester

harvester cloud provider can't run w/ selinux enforcing due to not setting seLinuxOptions on container securityContext

kasm chart can't run in pss restricted namespace due to db init container running as root

storage network

gpu/vgpu pci passthrough

ova import changing image

faster vm cloning both w/ kasm and without

linux-based vms (mostly rhel)

airgapping of experimental addons not included in installer iso

any other storage optimizations

## Pre-meet notes

Better coordinate in the future API changes to partners (validating webhook rejecting VM template)

Having trouble importing Harvester into Rancher

rancher-agent image pull error (probably ca trust)

kasm's vm doesn't show gpus

Cade Thomas will be there the whole time

## Post-meet notes

Issues dicovered:
- Cannot upload images through Rancher (solved - ingress settings, see https://docs.harvesterhci.io/v1.7/image/upload-image#http-413-error-in-rancher-multi-cluster-management)
- Instance manager pods cannot be recreated after storage network is set, due to CNI ADD operation failing on secondary multus network - suspicion is this is because whereabouts IPPool is not being created, but cannot tell why that happens
- `cattle-cluster-agent` Deployment is pre-pending `docker.io` to the image repo with `system-default-registry` set in Rancher, preventing Harvester cluster import without manually retagging the existing images
  - Should have been `<HARBOR_URL>/infrastructure/rancher/rancher-agent:v2.13.1` but was `<HARBOR_URL>/docker.io/infrastructure/rancher/rancher-agent:v2.13.1`
  - Details: community Rancher but govt Harvester - doesn't seem that should matter

Pain points:
- Creating a golden image
  - Exporting image from VM creates a raw backing image instead of qcow2 even though original image was qcow2
  - Backing image becomes 150Gi even though qcow2 was 23Gi and no files were added
  - Starting a new VM after this is extremely slow - 15 min compared to 2.5 min when booted from original qcow2
- Why does it take so long to boot from a large VM image in the first place?
  - This makes KASM autoscaling hell
  - Alleviated in practice at runtime by having a large minimum pool size, but if the pool gets exhausted, users will wait a very long time for a session
- Size of Harvester installer iso; >8Gi requires a Blu-Ray if you can't use USB