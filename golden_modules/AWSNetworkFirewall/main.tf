
############################################
# STATELESS RULE GROUPS
############################################
resource "aws_networkfirewall_rule_group" "stateless" {
  for_each = var.stateless_rule_groups

  capacity = each.value.capacity
  name     = each.value.name
  type     = "STATELESS"

  rule_group {
    rules_source {
      stateless_rules_and_custom_actions {
        dynamic "stateless_rule" {
          for_each = each.value.rules
          content {
            priority = stateless_rule.value.priority
            rule_definition {
              actions = stateless_rule.value.actions
              match_attributes {
                protocols = stateless_rule.value.protocols
                
                dynamic "source" {
                  for_each = [stateless_rule.value.source]
                  content {
                    address_definition = source.value
                  }
                }
                
                dynamic "destination" {
                  for_each = [stateless_rule.value.destination]
                  content {
                    address_definition = destination.value
                  }
                }
                
                dynamic "source_port" {
                  for_each = stateless_rule.value.source_ports
                  content {
                    from_port = source_port.value.from
                    to_port   = source_port.value.to
                  }
                }
                
                dynamic "destination_port" {
                  for_each = stateless_rule.value.destination_ports
                  content {
                    from_port = destination_port.value.from
                    to_port   = destination_port.value.to
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  tags = merge({ Name = each.value.name }, var.tags)
}

############################################
# STATEFUL RULE GROUPS
############################################
resource "aws_networkfirewall_rule_group" "stateful" {
  for_each = var.stateful_rule_groups

  capacity = each.value.capacity
  name     = each.value.name
  type     = "STATEFUL"

  rule_group {
    rules_source {
      rules_string = each.value.rules_string
    }
  }

  tags = merge({ Name = each.value.name }, var.tags)
}

############################################
# FIREWALL POLICY (References Rule Groups)
############################################
resource "aws_networkfirewall_firewall_policy" "policy" {
  name = var.firewall_policy_name

  firewall_policy {
    dynamic "stateless_rule_group_reference" {
      for_each = aws_networkfirewall_rule_group.stateless
      content {
        priority     = var.stateless_rule_groups[stateless_rule_group_reference.key].priority
        resource_arn = stateless_rule_group_reference.value.arn
      }
    }

    dynamic "stateful_rule_group_reference" {
      for_each = aws_networkfirewall_rule_group.stateful
      content {
        resource_arn = stateful_rule_group_reference.value.arn
      }
    }

    stateless_default_actions          = var.stateless_default_actions
    stateless_fragment_default_actions = var.stateless_fragment_default_actions
  }

  tags = merge({ Name = var.firewall_policy_name }, var.tags)
}

############################################
# NETWORK FIREWALL INSTANCE
############################################
resource "aws_networkfirewall_firewall" "fw" {
  name                = var.firewall_name
  firewall_policy_arn = aws_networkfirewall_firewall_policy.policy.arn
  vpc_id              = var.vpc_id

  dynamic "subnet_mapping" {
    for_each = var.firewall_subnet_ids
    content {
      subnet_id = subnet_mapping.value
    }
  }

  tags = merge({ Name = var.firewall_name }, var.tags)
}

############################################
# FIREWALL LOGGING CONFIGURATION
############################################
# resource "aws_networkfirewall_logging_configuration" "logs" {
#   count        = var.enable_logging && length(var.logging_destinations) > 0 ? 1 : 0
#   firewall_arn = aws_networkfirewall_firewall.fw.arn

#   logging_configuration {
#     dynamic "log_destination_config" {
#       for_each = var.logging_destinations
#       content {
#         log_destination_type = log_destination_config.value.type
#         log_type             = log_destination_config.value.log_type
#       }
#     }
#   }
# }
