locals {

# Common tags to be assigned to all resources

  common_tags = {
    Service = "test_service"
  }

# Application port to route traffic to
# number

  app_default_port = 8080

# HTTP/HTTPS protocol to address the instance
# string

  app_protocol = "HTTP"

# LB default port
# number

  lb_default_port = 443

# LB default protocol
# string

  lb_protocol = "HTTPS"

# Security group rule blocks to assign to ELB
#  type            = object({
#    ingress_rules = list(map(string))
#    egress_rules  = list(map(string))
#  })

  elb_sg_rules = {
      ingress_rules = [
          {
            from_port   = local.lb_default_port
            to_port     = local.lb_default_port
            protocol    = "tcp"
            description = "User-service ports (ipv4)"
            cidr_blocks = "0.0.0.0/0"
          },
        ]
      egress_rules = [
        {
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          description = "User-service ports (ipv4)"
          cidr_blocks = "0.0.0.0/0"
        }
      ]
  }

# type = object({
#      ingress_rules = list(map(string))
#      egress_rules  = list(map(string))
# })
# Security group rule blocks to assign to an application instance

  app_sg_rules = {
      ingress_rules = [
          {
            from_port   = local.app_default_port
            to_port     = local.app_default_port
            protocol    = "tcp"
            description = "User-service ports (ipv4)"
          },
        ]
      egress_rules = [
        {
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          description = "User-service ports (ipv4)"
          cidr_blocks = "0.0.0.0/0"
        }
      ]
    }

# list(map(string))
# Settings required to create ELB

  elb_listener = [
        {
          instance_port      = local.app_default_port
          instance_protocol  = lower(local.app_protocol)
          lb_port            = local.lb_default_port
          lb_protocol        = lower(local.lb_protocol)
          ssl_certificate_id = "arn:aws:iam::123456789012:server-certificate/certName"
        },
    ]

# map(string)
# Health check to perform on an instance before declaring healthy

  health_check = {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "${local.app_protocol}:${local.app_default_port}/health"
    interval            = 30
  }

}

variable "create_elb" {
  description = "Boolean parameter whether to create an elb"
  type    = bool
  default = true
}

variable "cross_zone_load_balancing" {
  description = "Boolean parameter to enable cross-zone load balancing"
  type        = bool
  default     = true
}

variable "idle_timeout" {
  description = "The time in seconds that the connection is allowed to be idle"
  type        = number
  default     = 60
}

variable "connection_draining" {
  description = "Boolean parameter to enable connection draining"
  type        = bool
  default     = false
}

variable "connection_draining_timeout" {
  description = "The time in seconds to allow for connections to drain"
  type        = number
  default     = 300
}

variable "elb_name" {
  description = "Name to assign to the ELB"
  type    = string
  default = "test-elb"
}

variable "vpc_id" {
  description = "VPC ID to create an ELB in"
  type    = string
  default = "vpc-11111111"
  validation {
    condition     = length(var.vpc_id) > 4 && substr(var.vpc_id, 0, 4) == "vpc-"
    error_message = "The vapv_id value must be a valid VPC id, starting with \"vpc-\"."
  }
}

variable "subnet_group_ids" {
  description = "Subnet Group IDs to create ELB in"
  type    = list(string)
  default = ["subnet-aaaaaaaa","subnet-bbbbbbbb"]
}

variable "s3_bucket_name" {
  description = "Name of a bucket to push logs into"
  type        = string
  default     = "tidal-logs"
}

variable "s3_prefix_name" {
  description = "Prefix in an S3 bucket with which to push logs"
  type        = string
  default     = "elb/"
}

variable "s3_logs_interval" {
  description = "Interval between the log push"
  type        = number
  default     = 5
}

variable "instances_ids"{
  description = "IDs of an instances to route traffic to"
  type        = list(string)
  default     = []
}
