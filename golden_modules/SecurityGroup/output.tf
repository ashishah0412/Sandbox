
output "security_group_ids" {
  description = "Security group IDs"
  value       = { for k, v in aws_security_group.sg : k => v.id }
}

output "security_group_arns" {
  description = "Security group ARNs"
  value       = { for k, v in aws_security_group.sg : k => v.arn }
}
