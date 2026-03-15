#!/bin/sh

set -xe

# EPEL rpm dynamically generates .repo files, so don't try to use cloud-init yumaddrepo
dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm
dnf install -y bat

curl -fsLS \
  https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 \
  -o /usr/local/bin/yq

systemctl enable --now tmp.mount
