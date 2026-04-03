data "http" "mykeys" {
  url = "https://github.com/adamacosta.keys"
}

module "server" {
  source = "../.."

  ami_owners          = ["amazon"]
  ami_prefix          = "RHEL-10"
  cloud_config_files  = [file("${path.module}/files/cloud-config.yaml")]
  cloud_init_scripts  = [file("${path.module}/scripts/init.sh")]
  ssh_authorized_keys = split("\n", trim(data.http.mykeys.response_body, "\n"))
}

output "server" {
  value = module.server
}