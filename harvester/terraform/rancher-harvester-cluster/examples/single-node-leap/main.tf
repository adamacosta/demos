terraform {
  required_providers {
    rancher2 = {
      source  = "rancher/rancher2"
      version = ">= 13.1"
    }
  }
}

provider "rancher2" {
  api_url   = "https://rancher.localdomain"
  token_key = "token-d4lzc:csf7pvmgqlbw9m5qnf9ndwvg54zqmzkvghpxn6wrggs9qlghsztgkq"
}

module "cluster" {
  source = "../.."

  cluster_name            = "single-node-leap"
  hvst_cluster_id         = "c-drkkh"
  hvst_sa_kubeconfig      = file("${path.module}/files/single-node-leap-kubeconfig")
  kubernetes_version      = "v1.34.4+rke2r1"
  network_name            = "vmnet1"
  registry_password       = "Rancher!234"
  registry_user           = "rancher"
  ssh_user                = "opensuse"
  system_default_registry = "registry.localdomain:5000"
  vm_namespace            = "homelab-demo"
  vmi_name                = "opensuse-leap-15-6"
}

output "kubeconfig" {
  sensitive = true
  value     = module.cluster.kubeconfig
}