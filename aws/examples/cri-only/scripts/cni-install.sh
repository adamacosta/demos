#!/bin/sh

set -xeo pipefail

# EPEL rpm dynamically generates .repo files, so don't try to use cloud-init yumaddrepo
dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm
dnf install -y bat neovim

CNI_PLUGINS_VERSION="1.8.0"
CONTAINERD_VERSION="2.2.0"
CRI_TOOLS_VERSION="1.34.0"
RUNC_VERSION="1.3.3"

ARCH="amd64"
OS="linux"

# Create and label directories where needed
mkdir /etc/containerd
mkdir -p /opt/cni/bin
# Built-in policy only expects unit files in /etc/systemd/system and /usr/lib/systemd/system
mkdir -p /usr/local/lib/systemd/system &&
semanage fcontext -a -r s0 -s system_u -t systemd_unit_file_t \
  /usr/local/lib/systemd/system &&
restorecon -v /usr/local/lib/systemd/system

# Acquire binaries for containerd, runc, crictl, and cni plugins
curl -fsLS \
  https://github.com/containerd/containerd/releases/download/v${CONTAINERD_VERSION}/containerd-${CONTAINERD_VERSION}-${OS}-${ARCH}.tar.gz |
  tar -C /usr/local -vxz

curl -fsLS \
  https://raw.githubusercontent.com/containerd/containerd/v${CONTAINERD_VERSION}/containerd.service \
  -o /usr/local/lib/systemd/system/containerd.service

curl -fsLS \
  https://github.com/opencontainers/runc/releases/download/v${RUNC_VERSION}/runc.${ARCH} \
  -o /usr/local/bin/runc

curl -fsLS \
  https://github.com/containernetworking/plugins/releases/download/v${CNI_PLUGINS_VERSION}/cni-plugins-${OS}-${ARCH}-v${CNI_PLUGINS_VERSION}.tgz |
  tar -C /opt/cni/bin -vxz

curl -fsLS \
  "https://github.com/kubernetes-sigs/cri-tools/releases/download/v${CRI_TOOLS_VERSION}/crictl-v${CRI_TOOLS_VERSION}-${OS}-${ARCH}.tar.gz" |
  tar -C /usr/local/bin -vxz

curl -fsLS \
  https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 \
  -o /usr/local/bin/yq

# Ensure all downloaded bins have correct permissions
find /usr/local/bin -type f -exec chmod 0755 {} \;

# Generate config.toml file for containerd
containerd config default | sed 's/SystemdCgroup = false/SystemdCgroup = true/' > /etc/containerd/config.toml

# Disable external access to NTP for CIS profile compliance
echo "cmdport 0" >> /etc/chrony.conf

# br_netfilter not included with default kernel modules
dnf install -y "kernel-modules-extra-$(uname -r)"

# Ensure kernel modules added to drop-in config are started
modprobe overlay
modprobe br_netfilter

# Create a CGroup systemd slice roughly equivalent to what kubelet would create
CPUS=$(lscpu --json | jq -r '.lscpu[] | select(.field=="On-line CPU(s) list:").data')
MEM=$(free --bytes | grep '^Mem' | awk '{print $2}')
TASKS=$(cat /proc/sys/kernel/threads-max)

cat <<EOF > /usr/local/lib/systemd/system/cni-pods.slice
[Install]
WantedBy=slices.target

[Unit]
Description=containerd cni-pods.slice
Wants=-.slice

[Slice]
MemoryAccounting=yes
CPUAccounting=yes
IOAccounting=yes
TasksAccounting=yes
AllowedCPUs=$CPUS
CPUWeight=157
MemoryMax=$MEM
TasksMax=$TASKS

[Unit]
DefaultDependencies=no
EOF

# Pick up new units and start services
systemctl daemon-reload
systemctl restart chronyd
systemctl restart systemd-sysctl
systemctl disable nm-cloud-setup
systemctl disable nm-cloud-setup.timer
systemctl enable --now tmp.mount
systemctl enable --now containerd
systemctl enable --now cni-pods.slice
