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

data "harvester_image" "sles16" {
  display_name = "SLES-16.0-Minimal-VM.x86_64-Cloud-QU1.qcow2"
  namespace    = "harvester-public"
}

module "vm" {
  source = "../.."

  network_name = "harvester-public/vmnet1"
  vm_cpus      = 4
  vm_image     = data.harvester_image.sles16.id
  vm_name      = "sles16-test"
  vm_namespace = "vms"
  vm_ram       = "8Gi"
}

output "primary_ip" {
  value = module.vm.primary_ip
}