
output "vpc_id" {
  value = aws_vpc.this.id
}

output "igw_id" {
  value = try(aws_internet_gateway.this[0].id, null)
}

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value       = try([for n in aws_nat_gateway.this : n.id], [])
}

output "nat_gateway_public_ips" {
  description = "Elastic IPs of NAT Gateways"
  value       = try([for eip in aws_eip.nat : eip.public_ip], [])
}

output "flow_logs_id" {
  value = try(aws_flow_log.this[0].id, null)
}

output "dhcp_options_id" {
  value = try(aws_vpc_dhcp_options.this[0].id, null)
}

output "dhcp_options_association_id" {
  value = try(aws_vpc_dhcp_options_association.this[0].id, null)
}
