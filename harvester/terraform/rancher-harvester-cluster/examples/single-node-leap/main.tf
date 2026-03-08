terraform {
  required_providers {
    rancher2 = {
      source  = "rancher/rancher2"
      version = ">= 13.1"
    }
    harvester = {
      source  = "harvester/harvester"
      version = ">= 0.6"
    }
  }
}

provider "rancher2" {
  api_url   = "https://rancher.localdomain"
  token_key = "token-d4lzc:csf7pvmgqlbw9m5qnf9ndwvg54zqmzkvghpxn6wrggs9qlghsztgkq"
}

provider "harvester" {
  kubeconfig  = "~/.kube/config"
  kubecontext = "homelab-harvester"
}

locals {
  name = "single-node-leap"
  namespace = "demo-cluster"
}

# IPPool for Ingress/API load balancers
resource "harvester_ippool" "ingress" {
  name = "${local.name}-ingress"

  range {
    end     = "192.168.3.50"
    gateway = "192.168.3.1"
    start   = "192.168.3.50"
    subnet  = "192.168.3.50/24"
  }

  selector {
    network  = "harvester-public/vmnet1"
    priority = 512
    scope {
      guest_cluster = local.name
      namespace     = local.namespace
    }
  }
}

module "cluster" {
  source = "../.."

  cluster_name            = local.name
  hvst_cluster_id         = "c-drkkh"
  hvst_sa_kubeconfig      = file("${path.module}/files/single-node-leap-kubeconfig")
  kubernetes_version      = "v1.34.4+rke2r1"
  network_name            = "vmnet1"
  registry_password       = "Rancher!234"
  registry_user           = "rancher"
  ssh_user                = "opensuse"
  system_default_registry = "registry.localdomain:5000"
  vm_namespace            = local.namespace
  vmi_name                = "opensuse-leap-15-6"
}

output "kubeconfig" {
  sensitive = true
  value     = module.cluster.kubeconfig
}