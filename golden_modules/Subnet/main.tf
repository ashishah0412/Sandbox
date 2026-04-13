
############################################
# SUBNETS
############################################
resource "aws_subnet" "this" {
  for_each = var.subnets

  vpc_id                  = var.vpc_id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = lookup(each.value, "map_public_ip", false)

  tags = merge(
    { Name = each.value.name },
    var.tags
  )
}

############################################
# LOCALS – Identify Subnets With NACL
############################################
locals {
  nacl_subnets = {
    for k, v in var.subnets :
    k => v
    if contains(keys(v), "nacl")
  }
}

############################################
# NETWORK ACL (ONE PER SUBNET – FULL CONTROL)
############################################
resource "aws_network_acl" "this" {
  for_each = local.nacl_subnets

  vpc_id = var.vpc_id

  tags = merge(
    { Name = "${each.value.name}-nacl" },
    var.tags
  )
}

############################################
# NACL ASSOCIATION
############################################
resource "aws_network_acl_association" "this" {
  for_each = local.nacl_subnets

  subnet_id      = aws_subnet.this[each.key].id
  network_acl_id = aws_network_acl.this[each.key].id
}

############################################
# INBOUND NACL RULES (FULLY DYNAMIC)
############################################
resource "aws_network_acl_rule" "inbound" {
  for_each = {
    for rule in flatten([
      for subnet_key, subnet in local.nacl_subnets : [
        for rule_index, rule_data in subnet.nacl.inbound : {
          composite_key = "${subnet_key}_${rule_data.rule_number}"
          subnet_key    = subnet_key
          rule          = rule_data
        }
      ]
    ]) : rule.composite_key => rule
  }
 
  network_acl_id = aws_network_acl.this[each.value.subnet_key].id
  egress         = false
 
  rule_number    = each.value.rule.rule_number
  rule_action    = each.value.rule.rule_action
  protocol       = each.value.rule.protocol
 
  cidr_block      = try(each.value.rule.cidr, null)
  from_port       = try(each.value.rule.from_port, null)
  to_port         = try(each.value.rule.to_port, null)
  # ... and so on for other attributes using each.value.rule.X
}
 

############################################
# OUTBOUND NACL RULES (FULLY DYNAMIC)
############################################
resource "aws_network_acl_rule" "outbound" {
  for_each = {
    for rule in flatten([
      for subnet_key, subnet in local.nacl_subnets : [
        for rule_index, rule_data in subnet.nacl.outbound : {
          composite_key = "${subnet_key}_${rule_data.rule_number}"
          subnet_key    = subnet_key
          rule          = rule_data
        }
      ]
    ]) : rule.composite_key => rule
  }
 
  network_acl_id = aws_network_acl.this[each.value.subnet_key].id
  egress         = true
 
  rule_number    = each.value.rule.rule_number
  rule_action    = each.value.rule.rule_action
  protocol       = each.value.rule.protocol
 
  cidr_block      = try(each.value.rule.cidr, null)
  from_port       = try(each.value.rule.from_port, null)
  to_port         = try(each.value.rule.to_port, null)
  # ... and so on for other attributes using each.value.rule.X
}
 
