terraform {
  required_version = ">= 0.13"
  required_providers {
    harvester = {
      source  = "harvester/harvester"
      version = ">= 0.6"
    }
  }
}

provider "harvester" {
  kubeconfig  = "~/.kube/config"
  kubecontext = "homelab"
}

data "harvester_image" "rocky9" {
  display_name = "Rocky-9-GenericCloud-Base.latest.x86_64.qcow2"
  namespace    = "harvester-public"
}

module "cp" {
  source = "../.."

  network_data = file("${path.module}/files/network-config.yaml")
  network_name = "harvester-public/vmnet1"
  num_vms      = 1
  user_data    = file("${path.module}/files/cloud-config.yaml")
  vm_cpus      = 1
  vm_image     = data.harvester_image.rocky9.id
  vm_name      = "rocky-test"
  vm_namespace = "vm-test"
  vm_ram       = "2Gi"
}

output "primary_ip" {
  value = module.cp.primary_ip
}