
output "route_table_ids" {
  description = "Map of Route Table IDs"
  value       = { for k, v in aws_route_table.rt : k => v.id }
}

output "route_table_associations" {
  description = "Map of Subnet Associations"
  value       = try({ for k, v in aws_route_table_association.assoc : k => v[*].id }, {})
}
