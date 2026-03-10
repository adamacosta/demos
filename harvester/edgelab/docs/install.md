# Harvester Installation

## Artifacts

ISO and PXE artifacts both available from <https://portal.ranchercarbide.dev/product/harvester>

Clickable download buttons generate pre-signed URLs to download from Amazon S3 in US GovCloud.

## Installation Process

[Upstream documentation](https://docs.harvesterhci.io/v1.7/install/index).

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

## Harvester config

[Upstream documentation](https://docs.harvesterhci.io/v1.7/install/harvester-configuration)

With ssh tunnel running, ssh to a node:

```sh
ssh rancher@10.240.0.10
```

See that Harvester config is available from physical server:

```console
rancher@hvst-0:~> curl http://10.240.0.2:8080/harvester-config.yaml
scheme_version: 1
token: acosta-edgelab
os:
  ssh_authorized_keys:
    - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCmO9+J1Q247bgXaRerwjYvILwQJS2DGvsVMZ9ctjWcAaoO6qv9kDgduIfdJ6zR+69HlXX51spk2N+N6wyKVr4WAHDDLTplzgXkXkor74LExOV9DUIyu4ibO4ZpKjncq/q7pLv1mNohkR334440OJKK4JBuQz/AnrkmSJia2qsrZpnysnlC+EbsbvtOoqPzN8hiiF/rFc7bXOmygEgKAZMrNss1wTQ6wCnBYmanjQgv8zXcpllmZrwBlJwng6veFI2F14D7G5SKGO2t1hWSNwe3qhtyuM27p7GRwD4qqT5u067yvGEdb3oWR2WUJEqY6YFz6HP3zWwvHFaUBBIziUZvZV4iv+GDsocXARg4fTw90lH5T8VFpluRO3VKcc9HQ3fYauAsQDqbevZv5G3c9rQ9195XIKCngIL0fIHn0TxaL8sMVs5DyLIlxLw2Rfz7l8dPDE3d4npeGk2uz0RdZ6JSJowOdAiUrnpoKPiHHLOft8ihRE68Kd49UtdeWbdhrXzK2EqQ6tUF7VVPzIn2fgO66+3nJrBy68e2HVFQEIJFOD00pkcuXLQudlPZE/xHljhFm1OoAvBoqXN7qmhts3SK/A2g3kzUlajkxFfDpv3qjT5v5vGCjRAqtxCvWA5BkeaF1DGas3mh/7sHsjhuZcGQkczYDIHSmuPkMWYc/6ebSw==
    - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDYL7fx3NcJVXhOZqPdlj+JEKKa5SCTy+EKdSFiCrEdDR47ScE0kROFWhy9n5ke2MJU2byEr12xeiJi6zl4tKUhUkNRD6UY0QWt2ZoB9dgcCzyk8z8hBcZzFitpR1Nt7ZnbEIMMvQLS8EH+qqH0XgHg7VUtoJ12Z4LTXIFEwx4xLn01bzNuZydfv6Kgllqsln6GEsKZbvwtV0OU4zExEt4TB5KsRWvTweLRp5mXZXmBGa1gt2fGLPEtQoLqUNa1JtrhLkpAzXEkNfzMUaMP1EH7Yn0erVE8aMQ/SjVNwn7DKWtJbRexPJiS9OTZrZ22iSQCXBXVyByDatQNw8Y1rTX//fU0vK1p8hjCr4qDfc15B7Wljn1hHumugzrpNKBlyb8omaqEOgCCKKIdjWc8a1uw3TzSheYL6rx5gPd3q5JKQATZBsov6FksAywzk8isQYY+c2XpVkyYqb8LxHfXYdfnRyUuMwHkgkNJvr/pTsxrUI0ld+6xFMgTidzkLfItv5QotLTyx/Oqjp1CSKvwR3BWGoCQ4/FX8d50sAwpUHPJudDC1IZZ1SAXIIJPFB1qRWZvTRNH7mDt6I01IuH8dFJsjSZ7IGYVAmUNbuvTcL/JMEzVnZBp7Mn9NRhu6Bm7c0uTx8hMlGrRLxkbZOljKcK6xtwzGbDdrhBmx7StNkZJnw==
    - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCw5E7wHOe5C9yjusPF97kgoBRVVAz5EskAjMYyLonbl6ZcJT/+sEDz41wUolQBqJkIrHLhoT5ChZ4kfNY2J7POSL+b7GyUF1wF5GiW35WmkimpPMI0cFxsQE51o7uB+PNnXxo0YisdSEevH2P85Ozi5r1bjy5BCSxgSUtiBuesss/0fpwTmWwIwYIF0J4a46wPJy+LAZ7qAzvw1MENwXT7i7QYNr53qPo0ZHsmEp32uhwcZBaXP73Wzul0WcuKt3JiYWUWMx6nBGliWzxUl7Wy4KNj1tMnAlEDt4JKteyd7b0XXq0LHpvKOaXOplMEMaHpJHJitqBmuy4eQaqwdMr6O6HrVF2gXxaux7XNH7GFZUEwPhzu/6sgESMav7wHINTjGY7UvZRZv5W8EguwdZZZLK19qdWn4+otgr+Qqi6BBqOndNQnQZPN5FMtqbbo4yJmO1aC21Ylqe5vm83a8joLUqTtwrpM3GxMdnddBvnVViXIiALsYbXzxqK3KLbPnTk=
    - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCtEHtli6UrbQlPc/d0Z79mDieb4tb00NsadYMN+OkiMCGuwG9STUzLT52+yfhw4D0F7OqZEbPbEK1mcCE4pUKUpbzJ05YDqJhZ7MGHx8EjCgsmfyvBDNqQsj4ycwM3cJN+v0rcT1D17LWBLMyx5IGzU6hF0qvATdSqzMkARCHx59FQM43OD6d1OiIUCuv673qwx6Ff16EjNKr9eZcvEQuHSJrNzm9406NBy9zs9FIDBgTiEBbx43+g7zRlWrsMkK7NQ1ayX98cipfnqBSAQFX9cosK8GLxCMrkPMp98E2uKNkisMO4xXwni6TvHV104Vuzn/MwJDMEhQmxzqSOfL+fI0Klt3KCVW5TN1Ww9BXGAJqSD1tN7ShHL8caM9fylaKh4ETl+ACLBqPmmJrx9LwbpjhOFBuWsco6XXPpfGneWkhPbtiWN0hXed6eXcJz/40GLgDzTp8UTchZgdHdfepQcsLvVRJwR8W0ocVZv6Z4LV9EY+B/0yixX0YLwO4wV7+4uxjos476mvIsUANUELapZTb2626kJC1tAp0vqoUpehcEET3B77PQ6hj8rECSDa1EUryNibUxdWIHOSqFRGvQzRz1HorPiPf4DJeUB9r/fQrwdFScNL0ErjQrq9sQ6N49ZnX0c+jStZwecIwxs1IJSCRP4qyUgsP9jyQXJEpfgQ==
install:
  addons:
    vm-import-controller:
      enabled: true
```

Allows setting of values not accessible to the installer tui, including, as we see here, the `vm-import-controller` optional addon we will use to demonstrate an OVA import. If using the PXE installer, all configuration values are passed via this file.
