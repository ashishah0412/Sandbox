
variable "vpc_id" {
  type        = string
  description = "VPC ID where subnets will be created"
}

variable "subnets" {
  description = "Subnet and NACL configuration"
  type = map(object({
    name               = string
    cidr               = string
    az                 = string
    map_public_ip      = optional(bool, false)

    # NACL configuration (optional)
    nacl = optional(object({
      shared_nacl_key = optional(string) # allow reuse of a shared NACL

      inbound = list(object({
        rule_number = number
        protocol    = string              # -1 | tcp | udp | icmp
        rule_action = string              # allow | deny
        cidr  = optional(string)
        ipv6_cidr_block = optional(string)
        from_port   = optional(string)
        to_port     = optional(string)
        icmp_type   = optional(number)
        icmp_code   = optional(number)
      }))

      outbound = list(object({
        rule_number = number
        protocol    = string
        rule_action = string
        cidr  = optional(string)
        ipv6_cidr_block = optional(string)
        from_port   = optional(string)
        to_port     = optional(string)
        icmp_type   = optional(number)
        icmp_code   = optional(number)
      }))
    }))
  }))
}

variable "tags" {
  type    = map(string)
  default = {}
}
