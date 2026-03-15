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
}

resource "aws_eip" "server_ip" {
  count = local.num_servers == 1 ? (var.create_eip ? 1 : 0) : 0

  network_interface = aws_instance.server[0].primary_network_interface_id
  domain            = "vpc"

  tags = {
    Name = local.tag_name
  }
}
