data "http" "mykeys" {
  url = "https://github.com/adamacosta.keys"
}

locals {
  resource_name = "rke2-multus-cilium"
}

module "server" {
  source = "../.."

  allowed_ingress_tcp_ports       = [6443]
  allowed_ingress_tcp_port_ranges = [{ from = 30000, to = 32767 }]
  allowed_ingress_udp_port_ranges = [{ from = 30000, to = 32767 }]
  allowed_self_tcp_ports          = [4244, 6443, 9345, 9963, 10250]
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
  create_eip             = true
  create_secondary_netif = true
  resource_name          = "${local.resource_name}-cp"
  ssh_authorized_keys    = split("\n", trim(data.http.mykeys.response_body, "\n"))
}

# module "agent" {
#   source = "../.."

#   allowed_self_tcp_ports          = [9345]
#   allowed_ingress_tcp_port_ranges = [{ from = 30000, to = 32767 }]
#   allowed_ingress_udp_port_ranges = [{ from = 30000, to = 32767 }]
#   ami_owners                      = ["amazon"]
#   ami_prefix                      = "RHEL-10"
#   cloud_config_files = [
#     file("${path.module}/files/cloud-config.yaml"),
#     templatefile("${path.module}/files/rke2-agent-cloud-config.yaml.tftpl", { server_ip = module.server.private_ips[0] })
#   ]
#   cloud_init_scripts = [
#     file("${path.module}/scripts/rke2-prereqs.sh"),
#     file("${path.module}/scripts/rke2-agent.sh")
#   ]
#   create_secondary_netif = true
#   extra_security_groups  = [module.server.internal_sg]
#   resource_name          = "${local.resource_name}-worker"
#   ssh_authorized_keys    = split("\n", trim(data.http.mykeys.response_body, "\n"))
# }

output "server" {
  value = module.server
}

# output "agent" {
#   value = module.agent
# }