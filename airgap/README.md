# Airgapping Rancher with Hauler

## Simulating airgap

If necessary, on the hosts you wish to deny Internet access, run the following:

```sh
sudo iptables -t filter -A OUTPUT -d 192.168.0.0/16 -j ACCEPT
sudo iptables -t filter -A OUTPUT -j DROP
```

Assuming your LAN subnet is 192.168.0.0/16. Else, substitute in the real subnet so your hosts can still access local resources we will use to stage required files.

## Credentials

Log into the Carbide registry:

```sh
echo "$CARBIDE_PASSWORD" | hauler login rgcrprod.azurecr.us -u "$CARBIDE_USER" --password-stdin
```

## RKE2

Find the latest stable version:

```sh
RKE2_VERSION=$(curl -sL https://update.rke2.io/v1-release/channels | jq -r '.data[] | select(.id=="stable").latest')
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

## Rancher

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
  --filename rancher-images.tar.zst \
  --store rancher-store
```

## RKE2 rpms

Hauler cannot currently act as an rpm fetcher. It is possible to install the `rke2` binary, `systemd` units, and config files from the release tarball, but this will not include SELinux policies. Instead, if these are needed, we can use `dnf` from any Internet-connected host. Create the following repo file (change channel as necessary when a higher stable version is available):

`/etc/yum.repos.d/rancher-rke2.repo`
```ini
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
sudo dnf --assume-yes install \
  --downloadonly \
  --downloaddir="$(pwd)/rpms" rke2-selinux rke2-server
```

Ensure you have the package `createrepo_c` and run:

```sh
createrepo_c "$(pwd)/rpms"
```

If you have a real webserver, use that to serve the files. For a quick and dirty temporary solution, you can use Python's built in http server:

```sh
python -m http.server --directory "$(pwd)/rpms"
```

Depending on the distro, `python` may still be `python3`.

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

And install:

```sh
sudo dnf install -y rke2-server
```
