
output "subnet_ids" {
  description = "List of all created subnet IDs"
  value       = { for k, v in aws_subnet.this : k => v.id }
}

output "nacl_ids" {
  description = "List of created Network ACL IDs"
  value       = try({ for k, v in aws_network_acl.this : k => v.id }, {})
}

// output "subnet_to_nacl_association" {
//   description = "NACL to Subnet Associations"
//   value       = try({ for k, v in aws_network_acl_association.nacl_assoc : k => v.id }, {})
// }
