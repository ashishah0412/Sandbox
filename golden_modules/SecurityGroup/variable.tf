
############################################
# REQUIRED
############################################

variable "vpc_id" {
  type        = string
  description = "VPC ID where security groups will be created"
}

############################################
# SECURITY GROUPS MAP
#
# Example structure:
#
# security_groups = {
#   app = {
#     name = "app-sg"
#     description = "Application SG"
#
#     ingress = [
#       {
#         from_port   = 80
#         to_port     = 80
#         protocol    = "tcp"
#         cidr_blocks = ["0.0.0.0/0"]
#       }
#     ]
#
#     egress = [
#       {
#         from_port   = 0
#         to_port     = 0
#         protocol    = "-1"
#         cidr_blocks = ["0.0.0.0/0"]
#       }
#     ]
#   }
# }
############################################

variable "security_groups" {
  type = map(object({
    name        = string
    description = optional(string)
    tags        = optional(map(string))

    ingress = list(object({
      from_port            = optional(number)
      to_port              = optional(number)
      protocol             = optional(string)
      cidr_blocks          = optional(list(string))
      ipv6_cidr_blocks     = optional(list(string))
      prefix_list_ids      = optional(list(string))
      source_sg_id         = optional(string)
    }))

    egress = list(object({
      from_port            = optional(number)
      to_port              = optional(number)
      protocol             = optional(string)
      cidr_blocks          = optional(list(string))
      ipv6_cidr_blocks     = optional(list(string))
      prefix_list_ids      = optional(list(string))
      source_sg_id         = optional(string)
    }))
  }))
}

############################################
# GLOBAL TAGS
############################################

variable "tags" {
  type    = map(string)
  default = {}
}
