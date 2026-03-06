# Third-Party CSI

## Prerequisites

Harvester already configured to use private registry. Add CA certificate to `additional-ca` setting.

## Copy images into local private registry

```sh
hauler store sync --filename manifests/csi-driver-nfs-manifest.yaml
hauler store copy registry://registry.localdomain:5000
```

## Helm install the NFS CSI driver

```sh
helm install csi-driver-nfs csi-driver-nfs/csi-driver-nfs \
  --namespace kube-system \
  --version v4.10.0 \
  --values manifests/csi-driver-nfs-values.yaml
```

## Create NFS PVC

```sh
kubectl create -f manifests/nfs-pvc.yaml
```

## Add to VM

Go to "Virtual Machines" tab, select a machine to edit, and select "+ Add Volume" from the upper right ellipsis menu.

![add volume](./static/add-volume.png)

## Check for new volume on VM

```console
$ lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
vda    253:0    0   30G  0 disk
├─vda1 253:1    0    2M  0 part
├─vda2 253:2    0   20M  0 part /boot/efi
└─vda3 253:3    0   30G  0 part /
vdb    253:16   0  100G  0 disk
vdc    253:32   0    1M  0 disk
```

`/dev/vda` is the root volume. `/dev/vdb` is the nfs volume we just added. `/dev/vdc` is the `cloud-init` CIDATA disk.

```console
$ sudo blkid /dev/vdc
/dev/vdc: BLOCK_SIZE="2048" UUID="2026-02-23-16-39-18-00" LABEL="cidata" TYPE="iso9660"
```

## Format and mount

```console
# mkfs.ext4 /dev/vdb
mke2fs 1.47.0 (5-Feb-2023)
Discarding device blocks: done
Creating filesystem with 26214400 4k blocks and 6553600 inodes
Filesystem UUID: eaaf08ce-f8d2-46c9-aa27-37e84d083bfa
Superblock backups stored on blocks:
	32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632, 2654208,
	4096000, 7962624, 11239424, 20480000, 23887872

Allocating group tables: done
Writing inode tables: done
Creating journal (131072 blocks): done
Writing superblocks and filesystem accounting information: done

# mount /dev/vdb /mnt
# echo "hello" > /mnt/hello.txt
# cat /mnt/hello.txt
hello
```
