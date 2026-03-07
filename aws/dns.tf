# this is assumed to already exist since we don't
# want to register a domain using terraform
data "aws_route53_zone" "domain" {
  count = length(var.dns_hosts) > 0 ? 1 : 0

  name = "rgsdemo.com."
}

resource "aws_route53_record" "host" {
  count = local.num_servers == 1 ? length(var.dns_hosts) : 0

  name    = "${var.dns_hosts[count.index]}.rgsdemo.com"
  records = var.create_eip ? [aws_eip.server_ip[0].public_ip] : [aws_instance.server[0].public_ip]
  ttl     = 300
  type    = "A"
  zone_id = data.aws_route53_zone.domain[0].zone_id
}
