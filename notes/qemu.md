# QEMU

[Upstream Documentation](https://www.qemu.org/docs/master/)

## SL Micro

### `cloud-init`

Mock a metadata server using `python -m http.server`, which will serve on port 8000 unless otherwise specified. `user-data` and `meta-data` are the only required files. You can put whatever cloud config you want in your `user-data`, but at least include:

```yaml
#cloud-config
chpaswd:
  expire: False
password: password
ssh_authorized_keys:
  - <YOUR_SSH_PUBKEY>
```

Then you can login to the guest with user:password `sles:password` or ssh using `ssh sles@<GUEST>`.

The `meta-data` file only needs to include an `instance-id` and it does not matter what it is:

```sh
cat <<EOF > meta-data
instance-id: i-$(openssl rand -hex 8)
EOF
```

Although not necessary, a minimal `network-config` file may also be provided:

```yaml
network:
  ethernets:
    eth0:
      dhcp4: true
      dhcp6: false
      dhcp-identifier: mac
  version: 2
```

### MacOS

```sh
qemu-system-x86_64 \
  -accel tcg \
  -cpu EPYC-v4 \
  -machine pc \
  -smp cpus=2 \
  -m 4096 \
  -nographic \
  -netdev user,id=nic-0,ipv6=off,net=10.240.10.0/24,dnssearch=localdomain,domainname=localdomain,hostfwd=tcp:127.0.0.1:2222-:22 \
  -device virtio-net-pci,netdev=nic-0,mac=52:54:00:12:34:56 \
  -drive file=/Users/adam.acosta/Downloads/SL-Micro.x86_64-6.2-Base-qcow-GM.qcow2,format=qcow2,if=virtio,index=0,media=disk \
  -smbios type=1,serial=ds='nocloud;s=http://10.240.10.2:8000/'
```

Explanation:
- `tcg` is the only accelerator available for arm64 Mac and is the default, but we specify it for clarity
- `cpu` has to be something that supports x86_86-v2 instruction set for SL Micro 6.x to work [^1]
- `machine` may be any that supports the required processor
- `user` mode host network has poor performance, but works without any further setup
  - We forward 2222 on the host to 22 in the guest to expose ssh
- `mac` has to start with `52:54` but may be any valid MAC address
  - `qemu` will set to `52:54:00:12:34:56` if not specified
  - We set it only because it must be unique per guest/interface if we use bridged networking
- `10.240.10.2` is the gateway address of the host, which defaults to the 2nd IP in the assigned subnet
  - We run an http server with `user-data` and `meta-data` files from this address for `cloud-init`
- `drive` only requires the filename, which must be fully-qualified

### Linux

```sh
qemu-system-x86_64 \
  -accel kvm \
  -cpu host \
  -machine pc \
  -smp cpus=2 \
  -m 4096 \
  -nographic \
  -bios /usr/share/edk2/x64/OVMF.4m.fd \
  -netdev user,id=nic-0,ipv6=off,net=10.240.10.0/24,dnssearch=localdomain,domainname=localdomain,hostfwd=tcp:127.0.0.1:2222-:22 \
  -device virtio-net-pci,netdev=nic-0,mac=52:54:00:12:34:56 \
  -drive file=/home/adam/images/SL-Micro.x86_64-6.2-Base-qcow-GM.qcow2,format=qcow2,if=virtio,index=0,media=disk \
  -smbios type=1,serial=ds='nocloud;s=http://10.240.10.2:8000/'
```

### Access guest from host

When the guest boots, it can be accessed either by logging into the console or via `ssh -p 2222 sles@127.0.0.1`.

### Using toolbox container

SL Micro does not come with much in the way of tooling. The intention is to use the `toolbox` script, which spawns a container, and perform troubleshooting actions from there. This defaults to pulling `registry.suse.com/suse/sles/toolbox:16.0`, which requires registration to install packages, so use the openSUSE Leap image instead by running:

```sh
toolbox create --img opensuse/leap:16.0 --reg docker.io --user
```

This will run `cloud-init` in the container to create a `sles` user with full sudo NOPASSWD privileges. The container will still be bare bones to begin, but you can install any packages available to Leap.

[^1]: [SL Micro migration from 5.5 to 6.x may fail with kernel panic because of unsupported CPU type](https://support.scc.suse.com/s/kb/SL-Micro-Migration-from-5-5-to-6-x-may-fail-with-kernel-panic-because-of-unsupported-CPU-type)