
output "firewall_arn" {
  value = aws_networkfirewall_firewall.fw.arn
}

output "firewall_policy_arn" {
  value = aws_networkfirewall_firewall_policy.policy.arn
}

output "firewall_endpoint_id" {
  description = "The VPC endpoint ID for the network firewall"
  value       = try(
    element([for sync_state in one(aws_networkfirewall_firewall.fw.firewall_status).sync_states : 
      sync_state.attachment[0].endpoint_id
    ], 0),
    null
  )
}

output "firewall_endpoint_ids_all" {
  description = "All VPC endpoint IDs for the network firewall (one per AZ)"
  value       = try(
    [for sync_state in one(aws_networkfirewall_firewall.fw.firewall_status).sync_states : 
      sync_state.attachment[0].endpoint_id
    ],
    []
  )
}

output "stateless_rule_group_arns" {
  value = { for k, v in aws_networkfirewall_rule_group.stateless : k => v.arn }
}

output "stateful_rule_group_arns" {
  value = { for k, v in aws_networkfirewall_rule_group.stateful : k => v.arn }
}
