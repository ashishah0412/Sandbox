
variable "region" {
  type = string
}

variable "vpc" {
  type = map(any)
}

variable "subnets" {
  type = map(any)
}

variable "route_tables" {
  type = map(any)
}

variable "security_groups" {
  type = map(any)
}

variable "network_firewall" {
  type = map(any)
}

variable "budgets" {
  type = map(any)
}

variable "tags" {
  type    = map(string)
  default = {}
}
