
output "budget_names" {
  description = "Names of the created AWS budgets"
  value       = { for k, v in aws_budgets_budget.this : k => v.name }
}

output "budget_arns" {
  description = "ARNs of created AWS budgets"
  value       = { for k, v in aws_budgets_budget.this : k => v.arn }
}
