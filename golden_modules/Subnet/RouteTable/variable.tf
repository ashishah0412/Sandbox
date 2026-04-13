
############################################
# REQUIRED VALUES
############################################

variable "vpc_id" {
  type        = string
  description = "VPC ID in which route tables should be created"
}

############################################
# ROUTE TABLE INPUT MAP
#
# Example:
# route_tables = {
#   public = {
#     name       = "public-rt"
#     subnet_ids = ["subnet-123", "subnet-456"]
#     routes = [
#       {
#         cidr        = "0.0.0.0/0"
#         gateway_id  = "igw-123456"
#       }
#     ]
#   }
# }
############################################

variable "route_tables" {
  type = map(object({
    name       = string
    subnet_ids = list(string)
    routes = list(object({
      cidr                    = optional(string)
      cidr_ipv6               = optional(string)
      gateway_id              = optional(string)
      nat_gateway_id          = optional(string)
      transit_gateway_id      = optional(string)
      vpc_peering_id          = optional(string)
      egress_only_gateway_id  = optional(string)
      tags                    = optional(map(string))
    }))
    tags = optional(map(string))
  }))
}

############################################
# GATEWAY REFERENCE MAPPINGS
############################################

variable "gateway_mappings" {
  description = "Map of gateway reference names to actual AWS resource IDs"
  type        = map(string)
  default     = {}
}

############################################
# GLOBAL TAGS
############################################

variable "tags" {
  type    = map(string)
  default = {}
}
