data "http" "mykeys" {
  url = "https://github.com/adamacosta.keys"
}

module "server" {
  source = "../.."

  ami_owners          = ["amazon"]
  ami_prefix          = "RHEL-10"
  cloud_config_files  = [for f in fileset(path.module, "files/*.yaml") : file(f)]
  cloud_init_scripts  = [for f in fileset(path.module, "scripts/*.sh") : file(f)]
  create_eip          = true
  resource_name       = "rke2-canal"
  ssh_authorized_keys = split("\n", trim(data.http.mykeys.response_body, "\n"))
}

output "server" {
  value = module.server
}