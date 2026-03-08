# Airgapping Rancher with Hauler

## Simulating airgap

If necessary, on the hosts you wish to deny Internet access, run the following:

```sh
sudo iptables -t filter -A OUTPUT -d 127.0.0.0/8 -j ACCEPT
sudo iptables -t filter -A OUTPUT -d 10.0.0.0/8 -j ACCEPT
sudo iptables -t filter -A OUTPUT -d 172.16.0.0/12 -j ACCEPT
sudo iptables -t filter -A OUTPUT -d 192.168.0.0/16 -j ACCEPT
sudo iptables -t filter -A OUTPUT -d 169.254.0.0/16 -j ACCEPT
sudo iptables -t filter -A OUTPUT -j DROP
```

## RKE2

Find the latest stable version:

```sh
RKE2_VERSION=$(curl -sL https://update.rke2.io/v1-release/channels | jq -r '.data[] | select(.id=="stable").latest')
```

### RKE2 rpms

Hauler cannot currently act as an rpm fetcher. It is possible to install the `rke2` binary, `systemd` units, and config files from the release tarball, but this will not include SELinux policies. Instead, if these are needed, we can use `dnf` from any Internet-connected host. Create the following repo file (change channel as necessary when a higher stable version is available):

```console
$ cat <<EOF | sudo tee /etc/yum.repos.d/rancher-rke2.repo
[rancher-rke2-common-stable]
name=Rancher RKE2 Common (stable)
baseurl=https://rpm.rancher.io/rke2/stable/common/centos/9/noarch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://rpm.rancher.io/public.key

[rancher-rke2-1.34-stable]
name=Rancher RKE2 1.34
baseurl=https://rpm.rancher.io/rke2/stable/1.34/centos/9/x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://rpm.rancher.io/public.key
EOF
```

Then download but do not install the rpms:

```sh
mkdir rpms &&
sudo dnf --assumeyes install \
  --downloadonly \
  --downloaddir="$(pwd)/rpms" rke2-server-$(sed 's/+/~/' <<<$RKE2_VERSION | sed 's/v//')
```

It is key when doing this to ensure that the system you're running this command on is the same base system you'll be using to deploy the Rancher cluster node VMs, because `dnf` will not reinstall dependencies that already exist on the system, such as `iptables-libs` for `iptables-nft` and all of the SELinux dependencies of `container-selinux`, which `rke2-selinux` extends.

Ensure you have the package `createrepo_c` and run:

```sh
createrepo_c "$(pwd)/rpms"
```

If you have a real webserver, use that to serve the files. For a quick and dirty temporary solution, you can use Python's built in http server:

```sh
python -m http.server --directory "$(pwd)/rpms"
```

Depending on the distro, `python` may still be `python3`.

You may also use `nginx` via a command like:

```sh
podman run \
  --name rpms \
  --mount "type=bind,source=$(pwd)/rpms,target=/usr/share/nginx/html,readonly" \
  --publish 8000:80 \
  --detach \
  docker.io/nginx
```

Then, on the host(s) that need to install these, create the repo file:

`/etc/yum.repos.d/rancher-rke2-local.repo`
```ini
[rancher-rke2-local]
name=Rancher RKE2 Local
baseurl=http://${HOST_IP}$:8000
enabled=1
gpgcheck=0
repo_gpgcheck=0
```

From the host(s) on which you wish to install these rpms, you can check that the repo is serving:

```sh
curl -I http://192.168.3.138:8000/repodata/repomd.xml
```

If that returns a 200, then you are good to go. To install:

```sh
sudo dnf install -y rke2-selinux rke2-server-$RKE2_VERSION
```

In the `terraform` example described below, this is done via `cloud-init`, assuming the VMs are created after the repo is in place and serving. The example host IP is specific to my home LAN, so please change it to match your network if adapted for your use.

### RKE2 container images

#### Hauler credentials

Log into the Carbide registry:

```sh
echo "$CARBIDE_PASSWORD" | hauler login rgcrprod.azurecr.us -u "$CARBIDE_USER" --password-stdin
```

Generate a manifest for RKE2 core and Cilium images:

```sh
./scripts/rke2-images.sh "$RKE2_VERSION"
```

Populate a Hauler store with the desired images:

```sh
hauler store sync \
  --filename rke2-manifest.yaml \
  --key files/carbide-key.pub \
  --platform linux/amd64 \
  --store rancher-store
```

## Rancher container images

You can the latest version of supported (non-community) Rancher either from the Carbide portal or from <https://prime.ribs.rancher.io>. Given that, generate a manifest for the required images:

```sh
./scripts/rancher-images.sh "$RANCHER_VERSION"
```

Now download these as well:

```sh
hauler store sync \
  --filename rancher-manifest.yaml \
  --key files/carbide-key.pub \
  --platform linux/amd64 \
  --store rancher-store
```

If you have a private registry running, you can copy the store to this:

```sh
hauler store copy \
  "registry://${REGISTRY_URL}:${REGISTRY_PORT}" \
  --store rancher-store
```

You can also save off the store as a tarred OCI blob store that can be loaded into the `containerd` image store when `rke2` first starts:

```sh
hauler store save \
  --containerd \
  --filename rancher-images.tar.zst \
  --store rancher-store
```

## Create VMs

Once this is complete, create the VMs that will run Rancher. An example is in this repo under `harvester/terraform/harvester-vm/examples/rancher`. This includes files needed to run the cluster correctly, pre-placed using the `write_files` module of `cloud-init`, which we can automatically generate.

### RKE2 Config Files

It includes the config files for `rke2` that are also found in the `files/` subdirectory of this instruction set:
- `/etc/rancher/rke2/audit-policy.yaml`
- `/etc/rancher/rke2/config.yaml`
- `/etc/rancher/rke2/rancher-pss.yaml`
- `/etc/rancher/rke2/registries.yaml`
- `/var/lib/rancher/rke2/server/manifests/rke2-cilium-config.yaml`

Other than the config values for `rke2-cilium`, these are not strictly needed, but provide `rke2` in the most fully-hardened state. Each of these can be adjusted to account for local policy.

To generate these:

```sh
./scripts/generate-config.sh
```

### Harvester Cloud Provider

Ensuring a namespace `rancher` exists in Harvester and your kubeconfig context is currently pointing to Harvester's API server, run the following:

```sh
./scripts/generate-addon.sh harvester-cloud-provider rancher
```

This will create a service account with required role bindings, grab its token, and put it into a kubeconfig base64-encoded, which gets printed to stdout with instructions to copy it to the `cloud-init` `user-data` of the VMs that will be running RKE2 on a guest cluster that needs to use the cloud provider. This is how we will provide the VIP for the API server and Rancher ingress.

## Using the airgap images

To make these available, we need to set the `system-default-registry` option in `rke2` to force `containerd` to resolve unqualified image references to either our private registry or the Carbide registry. If we copied these to a private, set it to that. Otherwise, set it to `systemd-default-registry: rgcrprod.azurecr.us`, which is what our example does, and then copy over the airgap tarball:

```sh
scp rancher-images.tar.zst rancher@192.168.3.31:~
scp rancher-images.tar.zst rancher@192.168.3.32:~
scp rancher-images.tar.zst rancher@192.168.3.33:~
```

Change the IPs to your host IPs if not using the same static assignments.

Log into that host, change ownership to root, and copy the tarball into `/var/lib/rancher/rke2/agent/images`.

```sh
sudo mkdir -p /var/lib/rancher/rke2/agent/images &&
sudo mv rancher-images.tar.zst /var/lib/rancher/rke2/agent/images/ &&
sudo chown root:root /var/lib/rancher/rke2/agent/images/rancher-images.tar.zst &&
sudo restorecon -vFFR /var/lib/rancher/rke2
```

## Starting RKE2

On your initializer node, simply run `systemctl enable --now rke2-server` to start the server. Once it is running, copy off the cluster's join token:

```sh
cat /var/lib/rancher/rke2/server/token
```

Add the following values to the `/etc/rancher/rke2/config.yaml` file on the other two nodes:

```yaml
server: https://${INIT_IP}:9345
token: ${TOKEN_FROM_ABOVE}
```

Then start `rke2` on the other two nodes.

## Install Rancher

Pull the Helm charts to your connected workstation:

```sh
helm pull oci://rgcrprod.azurecr.us/charts/cert-manager --version 1.19.4
helm pull oci://rgcrprod.azurecr.us/carbide-charts/rancher --version 2.13.3
```

To generate the `HelmChart` manifests, replace the `.spec.chartContent` with these charts:

```sh
cm="cert-manager-1.19.4.tgz" yq -i '.spec.chartContent = (load_str(strenv(cm)) | @base64)' manifests/cert-manager.yaml
rancher="$(base64 rancher-2.13.3.tgz)" yq -i '.spec.chartContent = strenv(rancher)' manifests/rancher.yaml
```

Then create the resource:

```sh
kubectl apply -f manifests/cert-manager.yaml
kubectl apply -f manifests/rancher.yaml
```

This is configured to use the self-signed CA auto-generated by Rancher, which takes a few minutes to set up the issuer.
