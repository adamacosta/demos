variable "allowed_ingress_cidr" {
  default     = null
  description = "CIDR to allow other ingress from - if not set, will inherit ssh ingress CIDR"
  type        = string
}

variable "allowed_ssh_cidr" {
  default     = null
  description = "CIDR to allow ssh ingress from - if not set, will use caller's IP address"
  type        = string
}

variable "allowed_ingress_tcp_ports" {
  default     = []
  description = "TCP ports to open for ingress other than ssh"
  type        = list(number)
}

variable "allowed_ingress_tcp_port_ranges" {
  default     = []
  description = "TCP port ranges to open for ingress other than ssh"
  type        = list(object({ from = number, to = number }))
}

variable "allowed_ingress_udp_ports" {
  default     = []
  description = "UDP ports to open for ingress other than ssh"
  type        = list(number)
}

variable "allowed_ingress_udp_port_ranges" {
  default     = []
  description = "UDP port ranges to open for ingress other than ssh"
  type        = list(object({ from = number, to = number }))
}

variable "allowed_self_tcp_ports" {
  default     = []
  description = "TCP ports to open within security group"
  type        = list(number)
}

variable "allowed_self_tcp_port_ranges" {
  default     = []
  description = "TCP port ranges to open within security group"
  type        = list(object({ from = number, to = number }))
}

variable "allowed_self_udp_ports" {
  default     = []
  description = "UDP ports to open within security group"
  type        = list(number)
}

variable "allowed_self_udp_port_ranges" {
  default     = []
  description = "UDP port ranges to open within security group"
  type        = list(object({ from = number, to = number }))
}

variable "ami_prefix" {
  # Beware this may require subscribing in advance,
  # which is a one-time op per account
  default     = "suse-sle-micro-6-*-llc-prod-*"
  description = "Prefix for AMI name to query for"
  type        = string
}

variable "ami_owners" {
  default     = ["aws-marketplace"]
  description = "List of account IDs or aliases that own the AMI"
  type        = list(string)
}

variable "aws_region" {
  default     = null
  description = "AWS region to create resources in"
  type        = string
}

variable "carbide_user" {
  default     = ""
  description = "User name for Carbide registry read token"
  type        = string
}

variable "cloud_config_files" {
  description = "List of cloud-config blocks to include in multipart MIME user-data for cloud-init"
  default     = []
  type        = list(string)
}

variable "cloud_init_scripts" {
  description = "List of user scripts to include in multipart MIME user-data for cloud-init"
  default     = []
  type        = list(string)
}

variable "create_eip" {
  default     = false
  description = "Create an Elastic IP to attach to server"
  type        = bool
}

variable "create_iam_dns_challenge" {
  default     = false
  description = "Create and attach IAM policy for cert-manager to create DNS01 challenge records for ACME protocol"
  type        = bool
}

variable "create_secondary_netif" {
  default     = false
  description = "Create and attach secondary network interface to server(s)"
  type        = bool
}

variable "deploy_rke2" {
  default     = false
  description = "Automatically deploy rke2 via cloud-init user data"
  type        = bool
}

variable "dns_domain" {
  default     = "rgsdemo.com."
  description = "Domain with a valid route53 public hosted zone. Defaults to rgsdemo.com, which has been pre-registered."
  type        = string
}

variable "dns_hosts" {
  default     = []
  description = "List of hosts to create A records for pointing to this server"
  type        = list(string)
}

variable "env_name" {
  default     = "demo"
  description = "Tag to add indicating environment ownership"
  type        = string
}

variable "extra_security_groups" {
  default     = []
  description = "Security groups to add to server interfaces"
  type        = list(string)
}

variable "instance_type" {
  default     = "m5a.xlarge"
  description = "Instance type of single-node cluster server (default m5a.xlarge)"
  type        = string
}

variable "num_servers" {
  default     = 1
  description = "Number of servers to create (default 1)"
  type        = number
}

variable "owner_name" {
  default     = null
  description = "Tag to add to resources indicating a human owner."
  type        = string
}

variable "resource_name" {
  default     = "test-server"
  description = "Name to add to resources that display this in AWS console"
  type        = string
}

variable "root_volume_size" {
  default     = "40"
  description = "Size of root volume may be smaller than AMI due to separate volumes for storage"
  type        = string
}

variable "root_volume_type" {
  default     = "gp3"
  description = "Volume type for root volume"
  type        = string
}

variable "ssh_authorized_keys" {
  default     = []
  description = "ssh pubkeys to add to default user's authorized_keys file"
  type        = list(string)
}

variable "tag_name" {
  default     = null
  description = "tag:Name to add to resources that display this in AWS console"
  type        = string
}

variable "tags" {
  default     = {}
  description = "Additional tags to add to all resources"
  type        = map(string)
}
