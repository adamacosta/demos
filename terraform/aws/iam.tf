## IAM
# EC2 instance profile with required API permissions
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "server" {
  name               = var.resource_name
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# This is needed to create ACME challenge DNS records
# https://cert-manager.io/docs/configuration/acme/dns01/route53/#set-up-an-iam-policy
data "aws_iam_policy_document" "route53_dns_challenge" {
  count = var.create_iam_dns_challenge ? 1 : 0

  statement {
    effect    = "Allow"
    actions   = ["route53:GetChange"]
    resources = ["arn:aws:route53:::change/*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "route53:ChangeResourceRecordSets",
      "route53:ListResourceRecordSets",
    ]
    resources = ["arn:aws:route53:::hostedzone/*"]

    condition {
      test     = "ForAllValues:StringEquals"
      variable = "route53:ChangeResourceRecordSetsRecordTypes"
      values   = ["TXT"]
    }
  }

  statement {
    effect    = "Allow"
    actions   = ["route53:ListHostedZonesByName"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "route53_dns_challenge" {
  count = var.create_iam_dns_challenge ? 1 : 0

  name        = "route53_dns_challenge"
  description = "Policy for cert-manager to manage dns challenges"
  policy      = data.aws_iam_policy_document.route53_dns_challenge[0].json
}

resource "aws_iam_role_policy_attachment" "server_dns_challenge" {
  count = var.create_iam_dns_challenge ? 1 : 0

  policy_arn = aws_iam_policy.route53_dns_challenge[0].arn
  role       = aws_iam_role.server.name
}

# This assumes a secret exists at a key equal to the user's name
locals {
  secret_arn = provider::aws::arn_build(
    local.aws_partition,
    "secretsmanager",
    local.aws_region,
    local.aws_account_id,
    "secret:rgcrprod.azurecr.us/${var.carbide_user}*"
  )
}

data "aws_iam_policy_document" "read_carbide_password" {
  count = var.carbide_user == "" ? 0 : 1

  statement {
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = [local.secret_arn]
  }
}

resource "aws_iam_policy" "read_carbide_password" {
  count = var.carbide_user == "" ? 0 : 1

  name        = "read_${var.carbide_user}"
  description = "Policy to read secret value at ${var.carbide_user}"
  policy      = data.aws_iam_policy_document.read_carbide_password[0].json
}

resource "aws_iam_role_policy_attachment" "read_carbide_password" {
  count = var.carbide_user == "" ? 0 : 1

  policy_arn = aws_iam_policy.read_carbide_password[0].arn
  role       = aws_iam_role.server.name
}

data "aws_iam_policy_document" "load_balancer" {
  statement {
    effect    = "Allow"
    actions   = [
      "ec2:DescribeInstances",
      "elasticloadbalancing:DescribeLoadBalancers",
      "elasticloadbalancing:DescribeTargetGroups",
      "elasticloadbalancing:DescribeTargetHealth"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "load_balancer" {
  name        = "${var.resource_name}-lb"
  description = "Policy to describe load balancers"
  policy      = data.aws_iam_policy_document.load_balancer.json
}

resource "aws_iam_role_policy_attachment" "load_balancer" {
  policy_arn = aws_iam_policy.load_balancer.arn
  role       = aws_iam_role.server.name
}

locals {
  token_secret_arn = provider::aws::arn_build(
    local.aws_partition,
    "secretsmanager",
    local.aws_region,
    local.aws_account_id,
    "secret:${var.resource_name}/token*"
  )
}

data "aws_iam_policy_document" "cluster_token" {
  statement {
    effect    = "Allow"
    actions   = [
      "secretsmanager:CreateSecret",
      "secretsmanager:ListSecrets"
    ]
    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:PutSecretValue"
    ]
    resources = [local.token_secret_arn]
  }
}

resource "aws_iam_policy" "cluster_token" {
  name        = "readwrite_${var.resource_name}"
  description = "Policy for secret value at ${var.resource_name}/token"
  policy      = data.aws_iam_policy_document.cluster_token.json
}

resource "aws_iam_role_policy_attachment" "cluster_token" {
  policy_arn = aws_iam_policy.cluster_token.arn
  role       = aws_iam_role.server.name
}