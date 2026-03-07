<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >=6.19 |
| <a name="requirement_cloudinit"></a> [cloudinit](#requirement\_cloudinit) | >=2.3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >=6.19 |
| <a name="provider_cloudinit"></a> [cloudinit](#provider\_cloudinit) | >=2.3 |
| <a name="provider_http"></a> [http](#provider\_http) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_eip.server_ip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_iam_instance_profile.server](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.read_carbide_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.route53_dns_challenge](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.server](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.read_carbide_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.server_dns_challenge](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_instance.server](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_network_interface.secondary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_interface) | resource |
| [aws_network_interface_attachment.test](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/network_interface_attachment) | resource |
| [aws_route53_record.host](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_security_group.external](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.internal](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_security_group_egress_rule.allow_all_traffic_ipv4](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.allow_ssh_ipv4](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.allowed_tcp_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.allowed_tcp_ingress_ranges](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.allowed_tcp_self](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.allowed_tcp_self_ranges](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.allowed_udp_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.allowed_udp_ingress_ranges](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.allowed_udp_self](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.allowed_udp_self_ranges](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_ami.server_base](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.read_carbide_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.route53_dns_challenge](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_route53_zone.domain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |
| [aws_subnets.selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_vpc.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |
| [cloudinit_config.server](https://registry.terraform.io/providers/hashicorp/cloudinit/latest/docs/data-sources/config) | data source |
| [http_http.myip](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_ingress_cidr"></a> [allowed\_ingress\_cidr](#input\_allowed\_ingress\_cidr) | CIDR to allow other ingress from - if not set, will inherit ssh ingress CIDR | `string` | `null` | no |
| <a name="input_allowed_ingress_tcp_port_ranges"></a> [allowed\_ingress\_tcp\_port\_ranges](#input\_allowed\_ingress\_tcp\_port\_ranges) | TCP port ranges to open for ingress other than ssh | `list(object({ from = number, to = number }))` | `[]` | no |
| <a name="input_allowed_ingress_tcp_ports"></a> [allowed\_ingress\_tcp\_ports](#input\_allowed\_ingress\_tcp\_ports) | TCP ports to open for ingress other than ssh | `list(number)` | `[]` | no |
| <a name="input_allowed_ingress_udp_port_ranges"></a> [allowed\_ingress\_udp\_port\_ranges](#input\_allowed\_ingress\_udp\_port\_ranges) | UDP port ranges to open for ingress other than ssh | `list(object({ from = number, to = number }))` | `[]` | no |
| <a name="input_allowed_ingress_udp_ports"></a> [allowed\_ingress\_udp\_ports](#input\_allowed\_ingress\_udp\_ports) | UDP ports to open for ingress other than ssh | `list(number)` | `[]` | no |
| <a name="input_allowed_self_tcp_port_ranges"></a> [allowed\_self\_tcp\_port\_ranges](#input\_allowed\_self\_tcp\_port\_ranges) | TCP port ranges to open within security group | `list(object({ from = number, to = number }))` | `[]` | no |
| <a name="input_allowed_self_tcp_ports"></a> [allowed\_self\_tcp\_ports](#input\_allowed\_self\_tcp\_ports) | TCP ports to open within security group | `list(number)` | `[]` | no |
| <a name="input_allowed_self_udp_port_ranges"></a> [allowed\_self\_udp\_port\_ranges](#input\_allowed\_self\_udp\_port\_ranges) | UDP port ranges to open within security group | `list(object({ from = number, to = number }))` | `[]` | no |
| <a name="input_allowed_self_udp_ports"></a> [allowed\_self\_udp\_ports](#input\_allowed\_self\_udp\_ports) | UDP ports to open within security group | `list(number)` | `[]` | no |
| <a name="input_allowed_ssh_cidr"></a> [allowed\_ssh\_cidr](#input\_allowed\_ssh\_cidr) | CIDR to allow ssh ingress from - if not set, will use caller's IP address | `string` | `null` | no |
| <a name="input_ami_owners"></a> [ami\_owners](#input\_ami\_owners) | List of account IDs or aliases that own the AMI | `list(string)` | <pre>[<br/>  "aws-marketplace"<br/>]</pre> | no |
| <a name="input_ami_prefix"></a> [ami\_prefix](#input\_ami\_prefix) | Prefix for AMI name to query for | `string` | `"suse-sle-micro-6-*-llc-prod-*"` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region to create resources in | `string` | `null` | no |
| <a name="input_carbide_user"></a> [carbide\_user](#input\_carbide\_user) | User name for Carbide registry read token | `string` | `""` | no |
| <a name="input_cloud_config_files"></a> [cloud\_config\_files](#input\_cloud\_config\_files) | List of cloud-config blocks to include in multipart MIME user-data for cloud-init | `list(string)` | `[]` | no |
| <a name="input_cloud_init_scripts"></a> [cloud\_init\_scripts](#input\_cloud\_init\_scripts) | List of user scripts to include in multipart MIME user-data for cloud-init | `list(string)` | `[]` | no |
| <a name="input_create_eip"></a> [create\_eip](#input\_create\_eip) | Create an Elastic IP to attach to server | `bool` | `false` | no |
| <a name="input_create_iam_dns_challenge"></a> [create\_iam\_dns\_challenge](#input\_create\_iam\_dns\_challenge) | Create and attach IAM policy for cert-manager to create DNS01 challenge records for ACME protocol | `bool` | `false` | no |
| <a name="input_create_secondary_netif"></a> [create\_secondary\_netif](#input\_create\_secondary\_netif) | Create and attach secondary network interface to server(s) | `bool` | `false` | no |
| <a name="input_deploy_rke2"></a> [deploy\_rke2](#input\_deploy\_rke2) | Automatically deploy rke2 via cloud-init user data | `bool` | `false` | no |
| <a name="input_dns_domain"></a> [dns\_domain](#input\_dns\_domain) | Domain with a valid route53 public hosted zone. Defaults to rgsdemo.com, which has been pre-registered. | `string` | `"rgsdemo.com."` | no |
| <a name="input_dns_hosts"></a> [dns\_hosts](#input\_dns\_hosts) | List of hosts to create A records for pointing to this server | `list(string)` | `[]` | no |
| <a name="input_env_name"></a> [env\_name](#input\_env\_name) | Tag to add indicating environment ownership | `string` | `"demo"` | no |
| <a name="input_extra_security_groups"></a> [extra\_security\_groups](#input\_extra\_security\_groups) | Security groups to add to server interfaces | `list(string)` | `[]` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Instance type of single-node cluster server (default m5a.xlarge) | `string` | `"m5a.xlarge"` | no |
| <a name="input_num_servers"></a> [num\_servers](#input\_num\_servers) | Number of servers to create (default 1) | `number` | `1` | no |
| <a name="input_owner_name"></a> [owner\_name](#input\_owner\_name) | Tag to add to resources indicating a human owner. | `string` | `null` | no |
| <a name="input_resource_name"></a> [resource\_name](#input\_resource\_name) | Name to add to resources that display this in AWS console | `string` | `"test-server"` | no |
| <a name="input_root_volume_size"></a> [root\_volume\_size](#input\_root\_volume\_size) | Size of root volume may be smaller than AMI due to separate volumes for storage | `string` | `"40"` | no |
| <a name="input_root_volume_type"></a> [root\_volume\_type](#input\_root\_volume\_type) | Volume type for root volume | `string` | `"gp3"` | no |
| <a name="input_ssh_authorized_keys"></a> [ssh\_authorized\_keys](#input\_ssh\_authorized\_keys) | ssh pubkeys to add to default user's authorized\_keys file | `list(string)` | `[]` | no |
| <a name="input_tag_name"></a> [tag\_name](#input\_tag\_name) | tag:Name to add to resources that display this in AWS console | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags to add to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_external_sg"></a> [external\_sg](#output\_external\_sg) | n/a |
| <a name="output_internal_sg"></a> [internal\_sg](#output\_internal\_sg) | n/a |
| <a name="output_private_ips"></a> [private\_ips](#output\_private\_ips) | n/a |
| <a name="output_public_ips"></a> [public\_ips](#output\_public\_ips) | n/a |
<!-- END_TF_DOCS -->