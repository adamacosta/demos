locals {
  network_name   = var.network_name
  root_disk_size = var.root_disk_size
  run_strategy   = var.run_strategy
  vm_cpus        = var.vm_cpus
  vm_image       = var.vm_image
  vm_name        = var.vm_name
  vm_namespace   = var.vm_namespace
  vm_ram         = var.vm_ram
}

resource "harvester_cloudinit_secret" "cloud-config" {
  name      = "cloud-config-${local.vm_name}"
  namespace = local.vm_namespace

  user_data    = <<-EOF
    #cloud-config
    package_update: true
    packages:
      - qemu-guest-agent
    runcmd:
      - - systemctl
        - enable
        - '--now'
        - qemu-guest-agent
      - - suseconnect
        - -r
        - INTERNAL-USE-ONLY-01e9-c544
    ssh_authorized_keys:
      - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGUV5mYJt2mNSayglG9+ez4W66Cj5PdBfvg5+Mqf+e9G
    EOF
  network_data = ""
}

resource "harvester_virtualmachine" "vm" {
  name                 = local.vm_name
  namespace            = local.vm_namespace
  restart_after_update = true

  cpu    = local.vm_cpus
  memory = local.vm_ram

  efi = true

  run_strategy = local.run_strategy
  hostname     = local.vm_name

  network_interface {
    name           = "nic-0"
    network_name   = local.network_name
    wait_for_lease = true
  }

  disk {
    name       = "rootdisk"
    type       = "disk"
    size       = local.root_disk_size
    bus        = "virtio"
    boot_order = 1

    image       = local.vm_image
    auto_delete = true
  }

  cloudinit {
    user_data_secret_name    = harvester_cloudinit_secret.cloud-config.name
    network_data_secret_name = harvester_cloudinit_secret.cloud-config.name
  }
}

output "primary_ip" {
  value = harvester_virtualmachine.vm.network_interface[0].ip_address
}