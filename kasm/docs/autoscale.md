# Harvester AutoScale

This is modified from the upstream docs in that we are not creating Windows templates and the `cloud-config` is modified to remove package updates and the apt wait, as well as to use the local source for the Kasm workspaces release tarball.

Use the following `cloud-config`:

```yaml
#cloud-config
users:
  - name: kasm-admin
    shell: /bin/bash
    lock_passwd: true
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_authorized_keys:
      - {ssh_key}
runcmd:
  - - systemctl
    - enable
    - --now
    - qemu-guest-agent.service
  - IP=$(ip route get 1.1.1.1 | grep -oP 'src \K\S+')
  - cd /tmp
  - wget http://192.168.3.138:8080/kasm_release_1.18.1.tar.gz -O kasm.tar.gz
  - tar -xf kasm.tar.gz
  - |
    if [ -z "$GIVEN_FQDN" ] ||  [ "$GIVEN_FQDN" == "None" ]  ;
    then
        AGENT_ADDRESS=$IP
    else
        AGENT_ADDRESS=$GIVEN_FQDN
    fi
  - bash kasm_release/install.sh -e -S agent -p $AGENT_ADDRESS -m {upstream_auth_address} -i {server_id} -r {provider_name} -M {manager_token}
  - rm kasm.tar.gz
  - rm -rf kasm_release
swap:
   filename: /var/swap.1
   size: 8589934592
```
