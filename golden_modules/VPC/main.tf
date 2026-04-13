
############################################
# VPC
############################################
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames
  instance_tenancy     = var.instance_tenancy

  assign_generated_ipv6_cidr_block = var.enable_ipv6

  tags = merge(
    { Name = "${var.name}-vpc" },
    var.tags
  )
}

############################################
# DHCP OPTIONS (Optional)
############################################
resource "aws_vpc_dhcp_options" "this" {
  count = var.enable_dhcp_options ? 1 : 0

  domain_name          = var.dhcp_domain_name
  domain_name_servers  = var.dhcp_domain_name_servers
  ntp_servers          = var.dhcp_ntp_servers
  netbios_name_servers = var.dhcp_netbios_name_servers
  netbios_node_type    = var.dhcp_netbios_node_type

  tags = merge(
    { Name = "${var.name}-dhcp-options" },
    var.tags
  )
}

resource "aws_vpc_dhcp_options_association" "this" {
  count = var.enable_dhcp_options ? 1 : 0

  vpc_id          = aws_vpc.this.id
  dhcp_options_id = aws_vpc_dhcp_options.this[0].id
}

############################################
# Internet Gateway
############################################
resource "aws_internet_gateway" "this" {
  count  = var.create_igw ? 1 : 0
  vpc_id = aws_vpc.this.id

  tags = merge(
    { Name = "${var.name}-igw" },
    var.tags
  )
}

############################################
# NAT Gateways (Optional)
############################################
/*
resource "aws_eip" "nat" {
  count = var.enable_nat_gateway ? var.nat_gateway_count : 0
  vpc   = true

  tags = merge(
    { Name = "${var.name}-nat-eip-${count.index}" },
    var.tags
  )
}

resource "aws_nat_gateway" "this" {
  count = var.enable_nat_gateway ? var.nat_gateway_count : 0

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = var.nat_gateway_subnet_ids[count.index]

  tags = merge(
    { Name = "${var.name}-nat-${count.index}" },
    var.tags
  )
}
*/
############################################
# VPC FLOW LOGS (S3 or CloudWatch)
############################################
resource "aws_flow_log" "this" {
  count = var.enable_flow_logs ? 1 : 0

  log_destination_type = var.flow_logs_destination_type
  traffic_type         = var.flow_logs_traffic_type
  vpc_id               = aws_vpc.this.id

  log_destination = (
    var.flow_logs_destination_type == "s3" ?
    var.flow_logs_s3_bucket_arn :
    aws_cloudwatch_log_group.vpc_flow_logs[0].arn
  )

  iam_role_arn = (
    var.flow_logs_destination_type == "cloud-watch-logs" ?
    aws_iam_role.vpc_flow_logs[0].arn : null
  )

  tags = merge(
    { Name = "${var.name}-vpc-flow-logs" },
    var.tags
  )
}

############################################
# CloudWatch Log Group (If using CloudWatch)
############################################
resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  count = var.enable_flow_logs && var.flow_logs_destination_type == "cloud-watch-logs" ? 1 : 0

  name              = "/aws/vpc/${var.name}-flow-logs"
  retention_in_days = var.flow_logs_retention

  tags = merge(
    { Name = "${var.name}-flow-logs" },
    var.tags
  )
}

############################################
# IAM Role for VPC Flow Logs (CloudWatch only)
############################################
resource "aws_iam_role" "vpc_flow_logs" {
  count = var.enable_flow_logs && var.flow_logs_destination_type == "cloud-watch-logs" ? 1 : 0

  name = "${var.name}-vpc-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "vpc-flow-logs.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "vpc_flow_logs" {
  count = var.enable_flow_logs && var.flow_logs_destination_type == "cloud-watch-logs" ? 1 : 0

  name = "${var.name}-vpc-flow-logs-policy"
  role = aws_iam_role.vpc_flow_logs[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      Resource = "*"
    }]
  })
}
