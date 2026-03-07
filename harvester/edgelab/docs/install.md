# Harvester Installation

## Artifacts

ISO and PXE artifacts both available from <https://portal.ranchercarbide.dev/product/harvester>

Clickable download buttons generate pre-signed URLs to download from Amazon S3 in US GovCloud.

## Installation Process

Upstream docs at [ISO Installation](https://docs.harvesterhci.io/v1.7/install/index).

### Hardware Checks

The Harvester installer checks hardware specs, requiring a minimum of 8 cores/32GiB RAM for testing and 16/64GiB for production. Because we only have test-compliant specs on our mini PCs, we have to confirm we wish to proceed.

### Inputs

- Installation mode
  - Create new cluster
  - Join existing cluster
  - Install binaries only
- Installation role
  - Default (management or worker)
  - Management
  - Witness
  - Worker
- Password for default user
  - `rancher`/`rancher` before
  - `rancher`/`${PASSWORD}` after
- Installation targets
  - Installation disk for operating system
  - Data disk for Longhorn
  - Persistent partition size if installation and data disk are the same
- Network
  - Management NIC
  - VLAN ID (optional)
  - Bond mode
  - IPv4 method (static or DHCP)
- Hostname (pre-filled if provided by DHCP)
- Cluster network
  - Pod CIDR (10.52.0.0/16)
  - Service CIDR (10.53.0.0/16)
  - Cluster DNS (10.53.0.10)
- DNS servers (blank uses default from DHCP)
- Management VIP
  - Mode (static or DHCP)
  - MAC address for DHCP
  - VIP for static
- Cluster token
- NTP servers
- HTTP proxy
- SSH key import
- Harvester configuration file URL

### Alternatives

- PXE/iPXE
- Customized ISO for auto-install

## Airgap Install

- All software is included in installer artifacts
- No Internet connection is required during installation
- DHCP required for PXE and/or dynamic IPs
- Installer tries to set interface(s) UP, requiring it to be plugged in
