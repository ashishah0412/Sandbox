
output "firewall_arn" {
  value = aws_networkfirewall_firewall.fw.arn
}

output "firewall_policy_arn" {
  value = aws_networkfirewall_firewall_policy.policy.arn
}

output "stateless_rule_group_arns" {
  value = { for k, v in aws_networkfirewall_rule_group.stateless : k => v.arn }
}

output "stateful_rule_group_arns" {
  value = { for k, v in aws_networkfirewall_rule_group.stateful : k => v.arn }
}
