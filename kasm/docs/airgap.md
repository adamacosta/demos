# Airgap Prep

We need to copy all required artifacts from upstream sources into our private network. This document describes how to do that.

## Prequisites

### Private CA

It is assumed that we have a private certificate authority. For my homelab, this was created using `cfssl` with a 5 year life and issues all of the certificates for internal applications.

### Private Registry

It is assumed that a private OCI registry is already available somewhere in this network. On my home network, this is a simply `registry2` container running on a TrueNAS server with the the URL `registry.localdomain` serving on port 5000. It is served over https using a certificate issued by the homelab CA.

### RPM Repository

We will describe how to create a private rpm repository and copy the required rpms into it.

### Carbide license

It is assumed you can login to the Carbide registry and portal in order to copy down required artifacts.

## Copy container images and Helm charts

### RKE2

Find the latest stable version:

```sh
RKE2_VERSION=$(curl -sL https://update.rke2.io/v1-release/channels | jq -r '.data[] | select(.id=="stable").latest')
```

Currently, this version is `v1.34.5+rke2r1`.

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

**NOTE**: Below commands must be run from the host you are using as an rpm repository server.

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

On my network, this host is at the IP `192.168.3.138`.

From any host(s) on the same network, you can check that the repo is serving. If it is working, you should see a response such as:

```console
$ curl -I http://192.168.3.138:8000/repodata/repomd.xml
HTTP/1.1 200 OK
Server: nginx/1.29.4
Date: Sun, 15 Mar 2026 18:26:35 GMT
Content-Type: text/xml
Content-Length: 1555
Last-Modified: Sun, 08 Mar 2026 10:37:55 GMT
Connection: keep-alive
ETag: "69ad5183-613"
Accept-Ranges: bytes
```

We handle creation of the repo and installation of the rpms via `cloud-init` `user-data` passed in when the VMs are created using the Terraform Harvester provider.

### RKE2 container images

Generate a Hauler manifest for RKE2 core, Cilium, and Harvester images:

```sh
./scripts/rke2-images.sh "$RKE2_VERSION"
```

Populate a Hauler store with the desired images and copy them to the private registry:

```sh
hauler store sync \
  --filename rke2-manifest.yaml \
  --key files/carbide-key.pub \
  --platform linux/amd64 \
  --store rke2-store

hauler store copy \
  registry://registry.localdomain:5000 \
  --store rke2-store
```

### Cert Manager

Grab the Helm chart and container images for `cert-manager` from the Carbide registry:

```sh
hauler store sync \
  --products apps-cert-manager=1.19.4 \
  --product-registry registry.ranchercarbide.dev \
  --platform linux/amd64 \
  --store cert-manager-store
```

Copy to private registry:

```sh
hauler store copy \
  registry://registry.localdomain:5000 \
  --store cert-manager-store
```

Pull the chart:

```sh
helm pull oci://registry.localdomain:5000/hauler/cert-manager --version 1.19.4
```

Copy the chart content into the `HelmChart` manifest:

```sh
cm="cert-manager-1.19.4.tgz" \
  yq -i '.spec.chartContent = (load_str(strenv(cm)) | @base64)' \
  manifests/cert-manager.yaml
```

### Pre-existing CA

Since we are using the same CA for all applications, we retrieve the existing configuration from Rancher. This is *not* stored in Git because it contains a private key that can sign valid certificates for my home network.

First, ensure we are pointing `kubectl` to Rancher's local cluster:

```sh
kubectl config use-context homelab-rancher
```

Copy off the CA key pair:

```sh
kubectl get secret \
  -n cert-manager \
  ca-key-pair -oyaml |
  yq 'del(.metadata.annotations,
          .metadata.creationTimestamp,
          .metadata.managedFields,
          .metadata.resourceVersion,
          .metadata.uid,
          .status)' \
  > manifests/ca-key-pair-secret.yaml
```

### Kasm Workspaces

#### Helm chart and container images

Kasm Workspaces Helm chart is still in beta status and only available directly from Github.

Clone the repo:

```sh
git clone git@github.com:kasmtech/kasm-helm.git
```

Package the chart:

```sh
helm package kasm-helm/charts/kasm
```

This leaves a tarball `kasm-1.1181.0.tgz`. We use this to generate a Hauler manifest for the images:

```sh
cat <<EOF > kasm-manifest.yaml
apiVersion: content.hauler.cattle.io/v1
kind: Images
metadata:
  name: apps-cert-manager-images
spec:
  images:
$(helm template kasm-1.1181.0.tgz | grep 'image:' | awk '{print $2}' | sort -u | sed 's/^/    - name: /')
EOF
```

Now pull these from upstream to copy to our private registry:

```sh
hauler store sync \
  --filename kasm-manifest.yaml \
  --platform linux/amd64 \
  --store kasm-store

hauler store copy \
  registry://registry.localdomain:5000 \
  --store kasm-store
```

Copy the chart content into the `HelmChart` manifest:

```sh
kasm="kasm-1.1181.0.tgz" \
  yq -i '.spec.chartContent = (load_str(strenv(kasm)) | @base64)' \
  manifests/kasm.yaml
```

#### Docker agent

We also need to pre-stage the Kasm Docker agent into our private network. This is preloaded onto the same server that serves the rpms but on a different port, in this case 8080 instead of 8000 for the rpm repository. Get it from the upstream source:

```sh
curl -fsLS \
  https://kasm-static-content.s3.amazonaws.com/kasm_release_1.18.1.tar.gz \
  --output "$HOME/images/kasm_release_1.18.1.tar.gz"
```

We also need the airgap tarballs for the container images that would get pulled at runtime:

```sh
curl -fsLS \
  https://kasm-static-content.s3.amazonaws.com/kasm_release_service_images_amd64_1.18.1.tar.gz \
  --output "$HOME/images/kasm_release_service_images_amd64_1.18.1.tar.gz"
curl -fsLS \
  https://kasm-static-content.s3.amazonaws.com/kasm_release_workspace_images_amd64_1.18.1.tar.gz \
  --output "$HOME/images/kasm_release_workspace_images_amd64_1.18.1.tar.gz"
curl -fsLS \
  https://kasm-static-content.s3.amazonaws.com/kasm_release_network_plugin_images_amd64_1.18.1.tar.gz \
  --output "$HOME/images/kasm_release_network_plugin_images_amd64_1.18.1.tar.gz"
curl -fsLS \
  https://kasm-static-content.s3.amazonaws.com/kasm_release_logging_plugin_images_amd64_1.18.1.tar.gz \
  --output "$HOME/images/kasm_release_logging_plugin_images_amd64_1.18.1.tar.gz"
```

Finally, we need the .deb packages for `docker` and `qemu-guest-agent` plus their dependencies:

```sh
curl -fsLS \
  https://download.docker.com/linux/ubuntu/dists/noble/pool/stable/amd64/containerd.io_2.2.2-1~ubuntu.24.04~noble_amd64.deb \
  --output "$HOME/images/containerd.io_2.2.2-1~ubuntu.24.04~noble_amd64.deb"
curl -fsLS \
  https://download.docker.com/linux/ubuntu/dists/noble/pool/stable/amd64/docker-buildx-plugin_0.31.1-1~ubuntu.24.04~noble_amd64.deb \
  --output "$HOME/images/docker-buildx-plugin_0.31.1-1~ubuntu.24.04~noble_amd64.deb"
curl -fsLS \
  https://download.docker.com/linux/ubuntu/dists/noble/pool/stable/amd64/docker-ce_29.3.0-1~ubuntu.24.04~noble_amd64.deb \
  --output "$HOME/images/docker-ce_29.3.0-1~ubuntu.24.04~noble_amd64.deb"
curl -fsLS \
  https://download.docker.com/linux/ubuntu/dists/noble/pool/stable/amd64/docker-ce-cli_29.3.0-1~ubuntu.24.04~noble_amd64.deb \
  --output "$HOME/images/docker-ce-cli_29.3.0-1~ubuntu.24.04~noble_amd64.deb"
curl -fsLS \
  https://download.docker.com/linux/ubuntu/dists/noble/pool/stable/amd64/docker-compose-plugin_5.1.0-1~ubuntu.24.04~noble_amd64.deb \
  --output "$HOME/images/ocker-compose-plugin_5.1.0-1~ubuntu.24.04~noble_amd64.deb"
curl -fsLS \
  http://mirrors.kernel.org/ubuntu/pool/main/libu/liburing/liburing2_2.5-1build1_amd64.deb \
  --output "$HOME/images/liburing2_2.5-1build1_amd64.deb"
curl -fsLS \
  http://security.ubuntu.com/ubuntu/pool/universe/q/qemu/qemu-guest-agent_8.2.2+ds-0ubuntu1.13_amd64.deb \
  --output "$HOME/images/qemu-guest-agent_8.2.2+ds-0ubuntu1.13_amd64.deb"
```

These can be found by searching the [Docker Ubuntu repo](https://download.docker.com/linux/ubuntu/dists/noble/pool/stable/amd64/) and [Ubuntu Noble package search](https://packages.ubuntu.com/noble/allpackages).

To start the server:

```sh
podman run \
  --name images \
  --mount "type=bind,source=$(pwd)/images,target=/usr/share/nginx/html,readonly" \
  --publish 8080:80 \
  --detach \
  docker.io/nginx
```

#### Workspace Images

Normally, Kasm pulls its workspaces images from Docker Hub as needed. The procedure we have described for airgapping thus far pulls in the following images to preload into Docker's local image store on the agent node:

```
kasmweb/ubuntu-jammy-desktop:1.18.0
kasmweb/firefox:1.18.0
kasmweb/chrome:1.18.0
kasmweb/terminal:1.18.0
```

There are, however, many other images available, and Kasm also allows you to use custom images. See [Default Docker Images](https://docs.kasm.com/docs/guide/custom_images) for a full list. Any of these that are wanted would need to be separately downloaded on an Internet-connected host and then transferred to the Docker agent for loading into the local image store.
