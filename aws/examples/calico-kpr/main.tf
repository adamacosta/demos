data "http" "mykeys" {
  url = "https://github.com/adamacosta.keys"
}

module "server" {
  source = "../.."

  allowed_ingress_tcp_ports = [6443]
  allowed_self_tcp_ports    = [6443, 9345]
  ami_owners                = ["amazon"]
  ami_prefix                = "RHEL-10"
  cloud_config_files = [
    file("${path.module}/files/cloud-config.yaml"),
    file("${path.module}/files/rke2-server-cloud-config.yaml")
  ]
  cloud_init_scripts  = [for f in fileset(path.module, "scripts/*.sh") : file(f)]
  create_eip          = true
  resource_name       = "rke2-calico-kpr"
  ssh_authorized_keys = split("\n", trim(data.http.mykeys.response_body, "\n"))
}

output "server" {
  value = module.server
}