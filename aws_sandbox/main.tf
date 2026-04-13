
###################################
# VPC
###################################
module "vpc" {
  source = "./../golden_modules/VPC"

  for_each = var.vpc

  name                       = each.value.name
  vpc_cidr                   = each.value.cidr
  create_igw                 = each.value.create_igw
  enable_dns_support         = each.value.enable_dns_support
  enable_dns_hostnames       = each.value.enable_dns_hostnames
  enable_nat_gateway         = coalesce(each.value.enable_nat_gateway, false)
  nat_gateway_count          = try(each.value.nat_gateway_count,null)
  nat_gateway_subnet_ids     = try(each.value.nat_gateway_subnet_ids,null)

  enable_dhcp_options        = false
  dhcp_domain_name           = try(each.value.dhcp_domain_name,null)
  dhcp_domain_name_servers   = try(each.value.dhcp_domain_name_servers,null)
  dhcp_ntp_servers           = try(each.value.dhcp_ntp_servers,null)

  enable_flow_logs           = each.value.enable_flow_logs
  flow_logs_destination_type = each.value.flow_logs_destination_type
  flow_logs_s3_bucket_arn    = each.value.flow_logs_s3_bucket_arn

  tags = var.tags
}

###################################
# SUBNETS + NACL
###################################
module "subnets" {
  source = "./../golden_modules/Subnet"

  for_each = var.subnets

  vpc_id      = module.vpc[each.value.vpc_key].vpc_id
  subnets     = each.value.subnets
  #create_nacl = each.value.create_nacl

  tags = var.tags
}

###################################
# ROUTE TABLES - GATEWAY ID RESOLUTION
###################################
locals {
  # Map gateway references to actual AWS resource IDs
  gateway_references = {
    "igw-sandbox" = module.vpc["main"].igw_id
    "local"       = "local"  # Special keyword, keep as-is
    # Add VPC endpoint references here once network_firewall module is enabled
    # "vpce-netfw"  = module.network_firewall["nfw-1"].firewall_endpoint_id
  }

  # Transform route_tables to resolve gateway_id references and subnet names to IDs
  resolved_route_tables = {
    for rt_key, rt_data in var.route_tables : rt_key => {
      vpc_key    = rt_data.vpc_key
      route_tables = {
        for rt_name, rt in rt_data.route_tables : rt_name => {
          name       = rt.name
          # Resolve subnet names to actual subnet IDs from the subnets module
          subnet_ids = [
            for subnet_name in rt.subnet_ids :
            module.subnets["subnet-set-1"].subnet_ids[subnet_name]
          ]
          routes = [
            for route in rt.routes : {
              cidr                    = try(route.cidr, null)
              cidr_ipv6               = try(route.cidr_ipv6, null)
              gateway_id              = try(contains(keys(local.gateway_references), route.gateway_id) ? local.gateway_references[route.gateway_id] : route.gateway_id, null)
              nat_gateway_id          = try(route.nat_gateway_id, null)
              transit_gateway_id      = try(route.transit_gateway_id, null)
              vpc_peering_id          = try(route.vpc_peering_id, null)
              egress_only_gateway_id  = try(route.egress_only_gateway_id, null)
            }
          ]
          tags = try(rt.tags, {})
        }
      }
    }
  }
}

###################################
# ROUTE TABLES
###################################
module "route_tables" {
  source = "./../golden_modules/Subnet/RouteTable"

  for_each = local.resolved_route_tables

  vpc_id       = module.vpc[each.value.vpc_key].vpc_id
  route_tables = each.value.route_tables

  tags = var.tags
}

###################################
# SECURITY GROUPS
###################################
module "security_groups" {
  source = "./../golden_modules/SecurityGroup"

  for_each = var.security_groups

  vpc_id          = module.vpc[each.value.vpc_key].vpc_id
  security_groups = each.value.security_groups

  tags = var.tags
}

###################################
# NETWORK FIREWALL
###################################

module "network_firewall" {
  source = "./../golden_modules/AWSNetworkFirewall"

  for_each = var.network_firewall

  vpc_id               = module.vpc[each.value.vpc_key].vpc_id
  firewall_name        = each.value.firewall_name
  firewall_policy_name = each.value.firewall_policy_name
  firewall_subnet_ids  = [module.subnets[each.value.subnet_key].subnet_ids["firewall-a"]]

  stateless_rule_groups  = each.value.stateless_rule_groups
  stateful_rule_groups   = each.value.stateful_rule_groups
  managed_rule_groups    = try(each.value.managed_rule_groups, {})

  enable_logging       = each.value.enable_logging
  logging_destinations = each.value.logging_destinations

  tags = var.tags
}


###################################
# BUDGETS
###################################
module "budgets" {
  source = "./../golden_modules/Automation"

  for_each = var.budgets

  budgets = each.value.budgets
  tags    = var.tags
}
