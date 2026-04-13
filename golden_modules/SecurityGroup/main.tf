
############################################
# SECURITY GROUPS (Dynamic)
############################################
resource "aws_security_group" "sg" {
  for_each = var.security_groups

  name        = each.value.name
  description = lookup(each.value, "description", each.value.name)
  vpc_id      = var.vpc_id

  revoke_rules_on_delete = true

  tags = merge(
    { Name = each.value.name },
    var.tags,
    lookup(each.value, "tags", {})
  )
}

############################################
# INGRESS RULES (Dynamic Per SG)
############################################
resource "aws_security_group_rule" "ingress" {
  for_each = {
    for rule in flatten([
      for sg_key, sg_data in var.security_groups : [
        for idx, rule_data in sg_data.ingress : {
          composite_key = "${sg_key}_ingress_${idx}"
          sg_key        = sg_key
          rule          = rule_data
        }
      ]
    ]) : rule.composite_key => rule
  }

  type              = "ingress"
  security_group_id = aws_security_group.sg[each.value.sg_key].id

  from_port   = each.value.rule.from_port
  to_port     = each.value.rule.to_port
  protocol    = coalesce(each.value.rule.protocol, "tcp")

  cidr_blocks              = try(each.value.rule.cidr_blocks, null)
  ipv6_cidr_blocks         = try(each.value.rule.ipv6_cidr_blocks, null)
  prefix_list_ids          = try(each.value.rule.prefix_list_ids, null)
  source_security_group_id = try(each.value.rule.source_sg_id, null)
}

############################################
# EGRESS RULES (Dynamic Per SG)
############################################
resource "aws_security_group_rule" "egress" {
  for_each = {
    for rule in flatten([
      for sg_key, sg_data in var.security_groups : [
        for idx, rule_data in sg_data.egress : {
          composite_key = "${sg_key}_egress_${idx}"
          sg_key        = sg_key
          rule          = rule_data
        }
      ]
    ]) : rule.composite_key => rule
  }

  type              = "egress"
  security_group_id = aws_security_group.sg[each.value.sg_key].id

  from_port   = try(each.value.rule.from_port, 0)
  to_port     = try(each.value.rule.to_port, 0)
  protocol    = coalesce(each.value.rule.protocol, "-1")

  cidr_blocks              = try(each.value.rule.cidr_blocks, null)
  ipv6_cidr_blocks         = try(each.value.rule.ipv6_cidr_blocks, null)
  prefix_list_ids          = try(each.value.rule.prefix_list_ids, null)
  source_security_group_id = try(each.value.rule.source_sg_id, null)
}
