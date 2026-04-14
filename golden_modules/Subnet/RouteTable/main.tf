
############################################
# ROUTE TABLE CREATION (Fully Dynamic)
############################################

resource "aws_route_table" "rt" {
  for_each = var.route_tables

  vpc_id = var.vpc_id

  tags = merge(
    {
      Name = each.value.name
    },
    var.tags,
    lookup(each.value, "tags", {})
  )
}

############################################
# ROUTES (Dynamic per Route Table)
############################################

resource "aws_route" "routes" {
  for_each = {
    for route in flatten([
      for rt_key, rt in var.route_tables : [
        for idx, route_data in rt.routes : {
          composite_key = "${rt_key}_${idx}"
          rt_key        = rt_key
          route         = route_data
        }
      ]
    ]) : route.composite_key => route
    # Skip local routes - AWS creates these automatically
    if route.route.gateway_id != "local"
  }

  route_table_id             = aws_route_table.rt[each.value.rt_key].id
  destination_cidr_block     = try(each.value.route.cidr, null)
  destination_ipv6_cidr_block = try(each.value.route.cidr_ipv6, null)

  # Resolve gateway_id references (igw-xxx, local, etc) through gateway_mappings
  # If resolved to a vpce-xxx ID, use vpc_endpoint_id instead
  gateway_id = try(
    (each.value.route.gateway_id == "local" ? 
      null : 
      (contains(keys(var.gateway_mappings), each.value.route.gateway_id) ? 
        (startswith(var.gateway_mappings[each.value.route.gateway_id], "vpce-") ? null : var.gateway_mappings[each.value.route.gateway_id]) :
        (startswith(each.value.route.gateway_id, "vpce-") ? null : each.value.route.gateway_id)
      )
    ),
    null
  )
  
  vpc_endpoint_id = try(
    (contains(keys(var.gateway_mappings), each.value.route.gateway_id) ?
      (startswith(var.gateway_mappings[each.value.route.gateway_id], "vpce-") ? var.gateway_mappings[each.value.route.gateway_id] : null) :
      (startswith(each.value.route.gateway_id, "vpce-") ? each.value.route.gateway_id : null)
    ),
    null
  )
  
  # Resolve nat_gateway_id references through gateway_mappings
  nat_gateway_id = try(
    (each.value.route.nat_gateway_id != null ?
      (contains(keys(var.gateway_mappings), each.value.route.nat_gateway_id) ?
        var.gateway_mappings[each.value.route.nat_gateway_id] :
        each.value.route.nat_gateway_id
      ) :
      null
    ),
    null
  )
  
  transit_gateway_id     = try(each.value.route.transit_gateway_id, null)
  vpc_peering_connection_id = try(each.value.route.vpc_peering_id, null)
  egress_only_gateway_id = try(each.value.route.egress_only_gateway_id, null)
}

############################################
# ROUTE TABLE ASSOCIATION (Subnet → RT)
############################################

resource "aws_route_table_association" "assoc" {
  for_each = {
    for assoc in flatten([
      for rt_key, rt in var.route_tables : [
        for idx, subnet_id in rt.subnet_ids : {
          composite_key = "${rt_key}_${idx}"
          rt_key        = rt_key
          subnet_id     = subnet_id
        }
      ]
    ]) : assoc.composite_key => assoc
  }

  subnet_id      = each.value.subnet_id
  route_table_id = aws_route_table.rt[each.value.rt_key].id
}
