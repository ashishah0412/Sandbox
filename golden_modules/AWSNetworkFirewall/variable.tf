
############################################
# CORE PARAMETERS
############################################
variable "vpc_id" {
  type = string
}

variable "firewall_name" {
  type = string
}

variable "firewall_policy_name" {
  type = string
}

variable "firewall_subnet_ids" {
  type = list(string)
}

############################################
# STATELESS RULE GROUPS
############################################
variable "stateless_rule_groups" {
  type = map(object({
    name     = string
    capacity = number
    priority = number
    rules = list(object({
      priority          = number
      actions           = list(string)
      source            = string
      destination       = string
      protocols         = list(number)
      source_ports      = list(object({ from = number, to = number }))
      destination_ports = list(object({ from = number, to = number }))
    }))
  }))
  default = {}
}

############################################
# STATEFUL RULE GROUPS
############################################
variable "stateful_rule_groups" {
  type = map(object({
    name         = string
    capacity     = number
    rules_string = string # Suricata rule string
  }))
  default = {}
}

############################################
# FIREWALL POLICY SETTINGS
############################################
variable "stateless_default_actions" {
  type    = list(string)
  default = ["aws:forward_to_sfe"]
}

variable "stateless_fragment_default_actions" {
  type    = list(string)
  default = ["aws:forward_to_sfe"]
}

############################################
# LOGGING
############################################
variable "enable_logging" {
  type    = bool
  default = false
}

variable "logging_destinations" {
  type = list(object({
    type        = string   # CloudWatchLogs | S3 | KinesisDataFirehose
    log_type    = string   # ALERT | FLOW
    destination = map(string)
  }))
  default = []
}

############################################
# TAGS
############################################
variable "tags" {
  type    = map(string)
  default = {}
}
