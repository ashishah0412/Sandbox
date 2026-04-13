
#######################################
# Core Inputs
#######################################
variable "name" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "enable_dns_support" {
  type    = bool
  default = true
}

variable "enable_dns_hostnames" {
  type    = bool
  default = true
}

variable "instance_tenancy" {
  type    = string
  default = "default"
}

variable "enable_ipv6" {
  type    = bool
  default = false
}

#######################################
# IGW + NAT Gateways
#######################################
variable "create_igw" {
  type    = bool
  default = true
}

variable "enable_nat_gateway" {
  type    = bool
  default = false
}

variable "nat_gateway_count" {
  type    = number
  default = 1
}

variable "nat_gateway_subnet_ids" {
  type        = list(string)
  default     = []
  description = "Subnet IDs where NAT gateways will be deployed"
}

#######################################
# DHCP Options
#######################################
variable "enable_dhcp_options" {
  type    = bool
  default = false
}

variable "dhcp_domain_name" {
  type    = string
  default = null
}

variable "dhcp_domain_name_servers" {
  type    = list(string)
  default = ["AmazonProvidedDNS"]
}

variable "dhcp_ntp_servers" {
  type    = list(string)
  default = []
}

variable "dhcp_netbios_name_servers" {
  type    = list(string)
  default = []
}

variable "dhcp_netbios_node_type" {
  type    = number
  default = null
}

#######################################
# Flow Logs
#######################################
variable "enable_flow_logs" {
  type    = bool
  default = false
}

variable "flow_logs_destination_type" {
  type    = string
  default = "cloud-watch-logs"
}

variable "flow_logs_traffic_type" {
  type    = string
  default = "ALL"
}

variable "flow_logs_s3_bucket_arn" {
  type    = string
  default = null
}

variable "flow_logs_retention" {
  type    = number
  default = 30
}

#######################################
# Tags
#######################################
variable "tags" {
  type    = map(string)
  default = {}
}
