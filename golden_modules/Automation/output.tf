
output "budget_names" {
  description = "Names of the created AWS budgets"
  value       = { for k, v in aws_budgets_budget.this : k => v.name }
}

output "budget_arns" {
  description = "ARNs of created AWS budgets"
  value       = { for k, v in aws_budgets_budget.this : k => v.arn }
}

output "budget_action_ids" {
  description = "IDs of created budget SCP actions"
  value       = { for k, v in aws_budgets_budget_action.scp_95 : k => v.action_id }
}

output "budget_action_arns" {
  description = "ARNs of created budget SCP actions"
  value       = { for k, v in aws_budgets_budget_action.scp_95 : k => v.arn }
}
