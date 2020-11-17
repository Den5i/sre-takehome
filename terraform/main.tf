# Minimal setup - best to use modules
# Provider/secrets/versions config is absent

# Default ELB AWS service account
data "aws_elb_service_account" "this" {}

# A tricky way of performing a check
# whether subnet ids provided belong
# to the provided VPC
data "aws_subnet" "check_exist" {
  for_each = toset(var.subnet_group_ids)
  id       = each.value
  vpc_id   = var.vpc_id
}

# Policy to allow ELB resource to access s3 bucket
data "aws_iam_policy_document" "logs" {
  statement {
    actions = [
      "s3:PutObject",
    ]

    principals {
      type        = "AWS"
      identifiers = [data.aws_elb_service_account.this.arn]
    }

    resources = [
      "arn:aws:s3:::${var.s3_bucket_name}/*",
    ]
  }
}

# Bucket to push ELB logs into
resource "aws_s3_bucket" "logs" {
  count         = var.create_elb ? 1 : 0
  bucket        = var.s3_bucket_name
  acl           = "private"
  policy        = data.aws_iam_policy_document.logs.json
  force_destroy = false
  tags          = local.common_tags
}

# A security group for ELB with dynamic blocks
# - just in case more than one ingress/egress rule
# will be provided 
resource "aws_security_group" "elb_sg" {
  name        = "ELB_SG"
  description = "Security group to assign to ELB"
  vpc_id      = var.vpc_id


  dynamic "ingress" {
    for_each                  = local.elb_sg_rules.ingress_rules
    content {
      from_port               = ingress.value.from_port
      to_port                 = ingress.value.to_port
      protocol                = ingress.value.protocol
      description             = ingress.value.description
      cidr_blocks             = split(",",ingress.value.cidr_blocks)
    }
  }

  dynamic "egress" {
    for_each                  = local.elb_sg_rules.egress_rules
    content {
      from_port               = egress.value.from_port
      to_port                 = egress.value.to_port
      protocol                = egress.value.protocol
      description             = egress.value.description
      cidr_blocks             = split(",",egress.value.cidr_blocks)
    }
  }
  tags                        = local.common_tags
}

# AWS ELB for balancing traffic accross instances
resource "aws_elb" "test_elb" {
  count                       = var.create_elb ? 1 : 0

  name                        = var.elb_name
  cross_zone_load_balancing   = var.cross_zone_load_balancing
  idle_timeout                = var.idle_timeout
  connection_draining         = var.connection_draining
  connection_draining_timeout = var.connection_draining_timeout
  subnets                     = var.subnet_group_ids
  security_groups             = [aws_security_group.elb_sg.id]

  access_logs {
    bucket                    = var.s3_bucket_name
    bucket_prefix             = var.s3_prefix_name
    interval                  = var.s3_logs_interval
  }

  dynamic "listener" {
    for_each                  = local.elb_listener
    content {
      instance_port           = listener.value.instance_port
      instance_protocol       = listener.value.instance_protocol
      lb_port                 = listener.value.lb_port
      lb_protocol             = listener.value.lb_protocol
      ssl_certificate_id      = lookup(listener.value, "ssl_certificate_id", null)
    }
  }

  health_check {
    healthy_threshold         = lookup(local.health_check, "healthy_threshold", "")
    unhealthy_threshold       = lookup(local.health_check, "unhealthy_threshold", "")
    target                    = lookup(local.health_check, "target", "")
    interval                  = lookup(local.health_check, "interval", "")
    timeout                   = lookup(local.health_check, "timeout", "")
  }

  tags                        = local.common_tags
}

resource "aws_security_group" "app_sg" {
  name        = "Application_SG"
  description = "AWS SG to assign to an instance"
  vpc_id      = var.vpc_id


  dynamic "ingress" {
    for_each                  = local.app_sg_rules.ingress_rules
    content {
      from_port               = ingress.value.from_port
      to_port                 = ingress.value.to_port
      protocol                = ingress.value.protocol
      description             = ingress.value.description
      cidr_blocks             = split(",", lookup(ingress.value, "cidr_blocks", ""))
      security_groups         = split(",", lookup(ingress.value, "security_groups", aws_security_group.elb_sg.id))
    }
  }

  dynamic "egress" {
    for_each                  = local.app_sg_rules.egress_rules
    content {
      from_port               = egress.value.from_port
      to_port                 = egress.value.to_port
      protocol                = egress.value.protocol
      description             = egress.value.description
      cidr_blocks             = split(",",egress.value.cidr_blocks)
    }
  }
  tags                        = local.common_tags
}

# other resources possible to use are
# aws_network_interface_sg_attachment and aws_security_group_rule
