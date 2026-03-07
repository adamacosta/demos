# Gateway Host

## Network Interfaces

### WAN

Connects to rest of home network.

`/etc/NetworkManager/system-connections/enp2s0.connection`

```ini
[connection]
autoconnect=true
autoconnect-slaves=-1
id=enp2s0
interface-name=enp2s0
type=802-3-ethernet
uuid=deaa31b8-bda4-5742-81eb-3c8d02e21cd7

[ipv4]
dhcp-client-id=mac
dhcp-send-hostname=true
dhcp-timeout=2147483647
ignore-auto-dns=false
ignore-auto-routes=false
method=auto
never-default=false

[ipv6]
addr-gen-mode=0
dhcp-timeout=2147483647
method=disabled

[ethernet]
cloned-mac-address=84:47:09:78:37:47
```

### LAN

Harvester cluster host network. VLAN1, untagged.

`/etc/NetworkManager/system-connections/enp3s0.connection`

```ini
[connection]
autoconnect=true
autoconnect-slaves=-1
id=enp3s0
interface-name=enp3s0
type=802-3-ethernet
uuid=bebd3c4c-78da-51a8-b371-839cdf2106f6

[ipv4]
address0=10.240.0.2/24
dhcp-timeout=2147483647
method=manual
route0=10.240.0.0/24,,1024
route0_options=table=254

[ipv6]
addr-gen-mode=0
dhcp-timeout=2147483647
method=disabled

[ethernet]
cloned-mac-address=84:47:09:78:37:49
```

VLAN10, tagged.

`/etc/NetworkManager/system-connections/vlan10.nmconnection`

```ini
[connection]
id=vlan10
uuid=d7fbb4a8-9e98-4ad8-840e-eb1ef2021a17
type=vlan

[vlan]
flags=1
id=10
parent=enp3s0

[ipv4]
address0=10.240.10.1/24
method=manual
route0=10.240.10.0/24,,1024
route0_options=table=254

[ipv6]
addr-gen-mode=0
method=disabled
```

VLAN20, tagged.

`/etc/NetworkManager/system-connections/vlan20.nmconnection`

```ini
[connection]
id=vlan20
uuid=7b06dd71-6ff0-4bdb-9147-28ca4fe7bf5e
type=vlan

[vlan]
flags=1
id=20
parent=enp3s0

[ipv4]
address0=10.240.20.1/24
method=manual
route0=10.240.20.0/24,,1024
route0_options=table=254

[ipv6]
addr-gen-mode=0
method=disabled
```

## DHCP

### VLAN1

`/etc/dnsmasq.d/localnet.conf`

```ini
interface=enp3s0
domain=edge.localdomain
dhcp-range=10.240.0.30,10.240.0.254,255.255.255.0
# Netgear GS108Tv3 switch
dhcp-host=28:94:01:7F:16:67,10.240.0.3
# Minisforum UM700 hvst-0
# enp2s0
dhcp-host=1c:83:41:28:ed:89,hvst-0,10.240.0.10
# Minisforum UM700 hvst-1
# enp2s0
dhcp-host=1c:83:41:28:ed:f9,hvst-1,10.240.0.11
# Minisforum UM700 hvst-2
# enp2s0
dhcp-host=1c:83:41:28:ef:6b,hvst-2,10.240.0.12
```

### VLAN10

`/etc/dnsmasq.d/vlan10.conf`

```ini
interface=enp3s0.10
dhcp-range=VLAN10,10.240.10.10,10.240.10.254,255.255.255.0
```

### VLAN20

`/etc/dnsmasq.d/vlan20.conf`

```ini
interface=enp3s0.20
dhcp-range=VLAN20,10.240.20.10,10.240.20.254,255.255.255.0
```

### Network segmentation with iptables

This prevents the gateway host from forwarding IP traffic between the two VLANs while allowing forwarding within the Harvester LAN or the home LAN, adding SNAT if forwarding to the home LAN so that return traffic is routeable.

```sh
sudo iptables -t filter -A INPUT -s 10.240.0.0/16 -d 10.240.0.0/16 -j RETURN
sudo iptables -t filter -A INPUT -s 10.240.0.0/16 -d 192.168.0.0/16 -j RETURN
sudo iptables -t filter -A INPUT -s 10.240.0.0/16 -j DROP
sudo iptables -t filter -A FORWARD -i enp3s0.10 -o enp3s0.20 -m state --state NEW -j DROP
sudo iptables -t filter -A FORWARD -i enp3s0.20 -o enp3s0.10 -m state --state NEW -j DROP
sudo iptables -t nat -A POSTROUTING -s 10.240.0.0/16 -d 192.168.0.0/16 -j MASQUERADE
```

## NGINX

This is used to serve the VM images and Harvester configuration.

### Create the serving directory on host

```sh
HTML_DIR="$HOME/html"
mkdir -p "$HTML_DIR"
chcon -Rv --type=container_file_t "$HTML_DIR"
semanage fcontext -a -t container_file_t "$HTML_DIR"
```

### Populate with files we wish to serve

```sh
curl -fL https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.ova \
  --output-dir "$HOME/html" \
  --remote-name
```

```sh
curl -fL https://download.opensuse.org/repositories/Cloud:/Images:/Leap_15.6/images/openSUSE-Leap-15.6.x86_64-NoCloud.qcow2 \
  --output-dir "$HOME/html" \
  --remote-name
```

### Start NGINX server

```sh
podman run \
  --name nginx \
  --mount type=bind,source=/home/rancher/html,target=/usr/share/nginx/html,readonly \
  --publish 8080:80 \
  --detach \
  docker.io/nginx
```