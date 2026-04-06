terraform {
  backend "s3" {
    bucket = "aacosta-tfstate"
    key    = "lhnet.tfstate"
    region = "us-east-2"
  }
}

data "http" "mykeys" {
  url = "https://github.com/adamacosta.keys"
}

locals {
  cluster_name = "lhnet"
}

module "server" {
  source = "../.."

  num_servers = 3

  allowed_ingress_cidr            = "0.0.0.0/0"
  allowed_ingress_tcp_ports       = [443, 6443, 9345]
  allowed_ingress_tcp_port_ranges = [{ from = 30000, to = 32767 }]
  allowed_ingress_udp_port_ranges = [{ from = 30000, to = 32767 }]
  allowed_self_tcp_ports          = [4240, 4244, 6443, 9345, 9963, 10250]
  allowed_self_tcp_port_ranges    = [{ from = 2379, to = 2382 }, { from = 30000, to = 32767 }]
  allowed_self_udp_ports          = [8472]
  allowed_self_udp_port_ranges    = [{ from = 30000, to = 32767 }]
  ami_owners                      = ["amazon"]
  ami_prefix                      = "RHEL-10"
  cloud_config_files = [
    file("${path.module}/files/cloud-config.yaml"),
    file("${path.module}/files/rke2-server-cloud-config.yaml")
  ]
  cloud_init_scripts = [
    file("${path.module}/scripts/rke2-prereqs.sh"),
    file("${path.module}/scripts/rke2-server.sh")
  ]
  create_secondary_netif = true
  lb_ports = [
    { port = 80, protocol = "TCP" },
    { port = 443, protocol = "TCP" },
    { port = 6443, protocol = "TCP" },
    { port = 9345, protocol = "TCP" }
  ]
  resource_name       = local.cluster_name
  root_volume_size    = "500"
  ssh_authorized_keys = split("\n", trim(data.http.mykeys.response_body, "\n"))

  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "owned"
  }
}

output "server" {
  value = module.server
}