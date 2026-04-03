## Network
# default VPC for chosen region
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "selected" {
  region = local.aws_region

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}

resource "aws_lb" "this" {
  name               = var.resource_name
  internal           = false
  load_balancer_type = "network"
  security_groups    = [aws_security_group.internal.id, aws_security_group.external.id]
  subnets            = data.aws_subnets.selected.ids

  tags = {
    Name = local.tag_name
  }
}

resource "aws_lb_target_group" "servers" {
  for_each = { for i, v in var.lb_ports : i => v }

  name     = "${var.resource_name}-${each.value.port}-${each.value.protocol}"
  port     = each.value.port
  protocol = each.value.protocol
  vpc_id   = data.aws_vpc.default.id
}

resource "aws_lb_listener" "servers" {
  for_each = { for i, v in var.lb_ports : i => v }

  load_balancer_arn = aws_lb.this.arn
  port              = each.value.port
  protocol          = each.value.protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.servers[each.key].arn
  }
}

locals {
  ids = aws_instance.server[*].id
  tgs = [for tg in aws_lb_target_group.servers: tg.arn]
  tg_attachments = flatten([
    for id in local.ids: [for tg in local.tgs: {id=id, tg=tg}]
  ])
}

resource "aws_lb_target_group_attachment" "server" {
  for_each = {for i, v in local.tg_attachments: i => v}

  target_group_arn = each.value.tg
  target_id = each.value.id
}

resource "aws_eip" "server_ip" {
  count = local.num_servers == 1 ? (var.create_eip ? 1 : 0) : 0

  network_interface = aws_instance.server[0].primary_network_interface_id
  domain            = "vpc"

  tags = {
    Name = local.tag_name
  }
}

output "lb_url" {
  value = aws_lb.this.dns_name
}