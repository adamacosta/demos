## Security groups
resource "aws_security_group" "external" {
  name        = "${var.resource_name}-external"
  description = "Allow inbound traffic for demo and all outbound traffic"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Name = "${local.tag_name}-external"
  }
}

resource "aws_security_group" "internal" {
  name        = "${var.resource_name}-internal"
  description = "Allow traffic between nodes"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Name = "${local.tag_name}-internal"
  }
}

# Mandatory for ssh access
resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.external.id
  cidr_ipv4         = local.allowed_ssh_cidr
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.external.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "allowed_tcp_ingress" {
  count = length(var.allowed_ingress_tcp_ports)

  cidr_ipv4         = local.allowed_ingress_cidr
  from_port         = var.allowed_ingress_tcp_ports[count.index]
  ip_protocol       = "tcp"
  security_group_id = aws_security_group.external.id
  to_port           = var.allowed_ingress_tcp_ports[count.index]
}

resource "aws_vpc_security_group_ingress_rule" "allowed_tcp_ingress_ranges" {
  count = length(var.allowed_ingress_tcp_port_ranges)

  cidr_ipv4         = local.allowed_ingress_cidr
  from_port         = var.allowed_ingress_tcp_port_ranges[count.index].from
  ip_protocol       = "tcp"
  security_group_id = aws_security_group.external.id
  to_port           = var.allowed_ingress_tcp_port_ranges[count.index].to
}

resource "aws_vpc_security_group_ingress_rule" "allowed_udp_ingress" {
  count = length(var.allowed_ingress_udp_ports)

  cidr_ipv4         = local.allowed_ingress_cidr
  from_port         = var.allowed_ingress_udp_ports[count.index]
  ip_protocol       = "udp"
  security_group_id = aws_security_group.external.id
  to_port           = var.allowed_ingress_udp_ports[count.index]
}

resource "aws_vpc_security_group_ingress_rule" "allowed_udp_ingress_ranges" {
  count = length(var.allowed_ingress_udp_port_ranges)

  cidr_ipv4         = local.allowed_ingress_cidr
  from_port         = var.allowed_ingress_udp_port_ranges[count.index].from
  ip_protocol       = "udp"
  security_group_id = aws_security_group.external.id
  to_port           = var.allowed_ingress_udp_port_ranges[count.index].to
}

resource "aws_vpc_security_group_ingress_rule" "allowed_tcp_self" {
  count = length(var.allowed_self_tcp_ports)

  from_port                    = var.allowed_self_tcp_ports[count.index]
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.internal.id
  security_group_id            = aws_security_group.internal.id
  to_port                      = var.allowed_self_tcp_ports[count.index]
}

resource "aws_vpc_security_group_ingress_rule" "allowed_tcp_self_ranges" {
  count = length(var.allowed_self_tcp_port_ranges)

  from_port                    = var.allowed_self_tcp_port_ranges[count.index].from
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.internal.id
  security_group_id            = aws_security_group.internal.id
  to_port                      = var.allowed_self_tcp_port_ranges[count.index].to
}

resource "aws_vpc_security_group_ingress_rule" "allowed_udp_self" {
  count = length(var.allowed_self_udp_ports)

  from_port                    = var.allowed_self_udp_ports[count.index]
  ip_protocol                  = "udp"
  referenced_security_group_id = aws_security_group.internal.id
  security_group_id            = aws_security_group.internal.id
  to_port                      = var.allowed_self_udp_ports[count.index]
}

resource "aws_vpc_security_group_ingress_rule" "allowed_udp_self_ranges" {
  count = length(var.allowed_self_udp_port_ranges)

  from_port                    = var.allowed_self_udp_port_ranges[count.index].from
  ip_protocol                  = "udp"
  referenced_security_group_id = aws_security_group.internal.id
  security_group_id            = aws_security_group.internal.id
  to_port                      = var.allowed_self_udp_port_ranges[count.index].to
}

## EC2 Instance Profile
# Uses role defined in iam.tf
resource "aws_iam_instance_profile" "server" {
  name = var.resource_name
  role = aws_iam_role.server.name
}

## Server
# EC2 with attached storage
data "cloudinit_config" "server" {
  gzip          = true
  base64_encode = true

  dynamic "part" {
    for_each = var.cloud_init_scripts

    content {
      filename     = "${part.key}-init.sh"
      content_type = "text/x-shellscript"
      content      = part.value
    }
  }

  part {
    filename     = "cloud-config.yaml"
    content_type = "text/cloud-config"

    content = templatefile(
      "${path.module}/files/cloud-config.tftpl.hcl",
      { ssh_authorized_keys = var.ssh_authorized_keys }
    )
  }

  dynamic "part" {
    for_each = var.cloud_config_files

    content {
      filename     = "${part.key}-cloud-config.yaml"
      content_type = "text/cloud-config"
      content      = part.value
    }
  }
}

data "aws_ami" "server_base" {
  most_recent = true
  owners      = var.ami_owners

  filter {
    name   = "name"
    values = ["${var.ami_prefix}*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "server" {
  count = local.num_servers

  ami                         = data.aws_ami.server_base.id
  associate_public_ip_address = !var.create_eip
  iam_instance_profile        = aws_iam_instance_profile.server.name
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnets.selected.ids[0]
  user_data_base64            = data.cloudinit_config.server.rendered
  vpc_security_group_ids = concat([
    aws_security_group.external.id,
    aws_security_group.internal.id
  ], var.extra_security_groups)

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = var.root_volume_type
  }

  metadata_options {
    http_put_response_hop_limit = 3 # default of 1 won't work for containerized cert-manager
    http_tokens                 = "required"
    instance_metadata_tags      = "disabled" # 'kubernetes.io/cluster/$NAME' disallowed
  }

  tags = {
    Name               = "${local.tag_name}-${count.index}"
    RKE2_SUPERVISOR_TG = "${var.resource_name}-9345-TCP"
  }
}

resource "aws_network_interface" "secondary" {
  count = var.create_secondary_netif ? local.num_servers : 0

  security_groups = concat(
    [aws_security_group.internal.id],
    var.extra_security_groups
  )
  subnet_id = data.aws_subnets.selected.ids[0]
}

resource "aws_network_interface_attachment" "test" {
  count = var.create_secondary_netif ? local.num_servers : 0

  instance_id          = aws_instance.server[count.index].id
  network_interface_id = aws_network_interface.secondary[count.index].id
  device_index         = 1
}

output "external_sg" {
  value = aws_security_group.external.id
}

output "internal_sg" {
  value = aws_security_group.internal.id
}

output "private_ips" {
  value = aws_instance.server[*].private_ip
}

output "public_ips" {
  value = var.create_eip ? [aws_eip.server_ip[0].public_ip] : aws_instance.server[*].public_ip
}