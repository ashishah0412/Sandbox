region = "us-east-1"
tags = {
  Environment = "prod"
  Owner = "Kowsik"
}
vpc = {
  main = {
    name = "vpc-bu1-us-east-1-sandbox"
    cidr = "10.10.0.0/16"
    create_igw = true
    enable_dns_support = true
    enable_dns_hostnames = true
    enable_nat_gateway = false
    enable_flow_logs = true
    flow_logs_destination_type = "cloud-watch-logs"
    flow_logs_s3_bucket_arn = null
  }
}
subnets = {
  "subnet-set-1" = {
    vpc_key = "main"
    create_nacl = true
    subnets = {
      "public-a" = {
        name = "subnet-bu1-us-east-1-sandbox-public"
        cidr = "10.10.0.0/25"
        az = "us-east-1a"
        map_public_ip = true
        nacl = {
          inbound = [
            {
              rule_number = 100
              protocol = "-1"
              from_port = 0
              to_port = 0
              cidr = "10.10.0.128/27"
              rule_action = "allow"
            },
            {
              rule_number = 110
              protocol = "tcp"
              from_port = 0
              to_port = 0
              cidr = "10.10.0.0/25"
              rule_action = "allow"
            },
            {
              rule_number = 120
              protocol = "tcp"
              from_port = 443
              to_port = 443
              cidr = "0.0.0.0/0"
              rule_action = "allow"
            },
            {
              rule_number = 130
              protocol = "tcp"
              from_port = 80
              to_port = 80
              cidr = "0.0.0.0/0"
              rule_action = "allow"
            },
            {
              rule_number = 140
              protocol = "tcp"
              from_port = 1024
              to_port = 65535
              cidr = "0.0.0.0/0"
              rule_action = "allow"
            },
            {
              rule_number = 150
              protocol = "udp"
              from_port = 53
              to_port = 53
              cidr = "10.10.0.0/16"
              rule_action = "allow"
            },
            {
              rule_number = 32766
              protocol = "-1"
              from_port = 0
              to_port = 0
              cidr = "0.0.0.0/0"
              rule_action = "deny"
            },
          ]
          outbound = [
            {
              rule_number = 100
              protocol = "-1"
              from_port = 0
              to_port = 0
              cidr = "10.10.0.128/27"
              rule_action = "allow"
            },
            {
              rule_number = 110
              protocol = "tcp"
              from_port = 0
              to_port = 0
              cidr = "10.10.0.0/25"
              rule_action = "allow"
            },
            {
              rule_number = 120
              protocol = "tcp"
              from_port = 1024
              to_port = 65535
              cidr = "0.0.0.0/0"
              rule_action = "allow"
            },
            {
              rule_number = 130
              protocol = "udp"
              from_port = 53
              to_port = 53
              cidr = "10.10.0.0/16"
              rule_action = "allow"
            },
            {
              rule_number = 32766
              protocol = "-1"
              from_port = 0
              to_port = 0
              cidr = "0.0.0.0/0"
              rule_action = "deny"
            }
          ]
        }
      }
      "private-a" = {
        name = "subnet-bu1-us-east-1-sandbox-private"
        cidr = "10.10.4.0/22"
        az = "us-east-1a"
        nacl = {
          inbound = [
            {
              rule_number = 100
              protocol = "tcp"
              from_port = 0
              to_port = 0
              cidr = "10.10.0.128/27"
              rule_action = "allow"
            },
            {
              rule_number = 110
              protocol = "tcp"
              from_port = 0
              to_port = 0
              cidr = "10.10.4.0/22"
              rule_action = "allow"
            },
            {
              rule_number = 120
              protocol = "tcp"
              from_port = 1024
              to_port = 65535
              cidr = "0.0.0.0/0"
              rule_action = "allow"
            },
            {
              rule_number = 130
              protocol = "udp"
              from_port = 53
              to_port = 53
              cidr = "10.10.0.0/16"
              rule_action = "allow"
            },
            {
              rule_number = 32766
              protocol = "-1"
              from_port = 0
              to_port = 0
              cidr = "0.0.0.0/0"
              rule_action = "deny"
            },
          ]
          outbound = [
            {
              rule_number = 100
              protocol = "-1"
              from_port = 0
              to_port = 0
              cidr = "10.10.0.128/27"
              rule_action = "allow"
            },
            {
              rule_number = 110
              protocol = "tcp"
              from_port = 0
              to_port = 0
              cidr = "10.10.4.0/22"
              rule_action = "allow"
            },
            {
              rule_number = 120
              protocol = "tcp"
              from_port = 1024
              to_port = 65535
              cidr = "0.0.0.0/0"
              rule_action = "allow"
            },
            {
              rule_number = 130
              protocol = "udp"
              from_port = 53
              to_port = 53
              cidr = "10.10.0.0/16"
              rule_action = "allow"
            },
            {
              rule_number = 32766
              protocol = "-1"
              from_port = 0
              to_port = 0
              cidr = "0.0.0.0/0"
              rule_action = "deny"
            }
          ]
        }
      }
      "firewall-a" = {
        name = "subnet-bu1-us-east-1-sandbox-firewall"
        cidr = "10.10.0.128/27"
        az = "us-east-1a"
        nacl = {
          inbound = [
            {
              rule_number = 100
              protocol = "-1"
              from_port = 0
              to_port = 0
              cidr = "10.10.0.0/25"
              rule_action = "allow"
            },
            {
              rule_number = 110
              protocol = "-1"
              from_port = 0
              to_port = 0
              cidr = "10.10.4.0/22"
              rule_action = "allow"
            },
            {
              rule_number = 120
              protocol = "tcp"
              from_port = 1024
              to_port = 65535
              cidr = "0.0.0.0/0"
              rule_action = "allow"
            },
            {
              rule_number = 130
              protocol = "tcp"
              from_port = 80
              to_port = 443
              cidr = "0.0.0.0/0"
              rule_action = "allow"
            },
            {
              rule_number = 140
              protocol = "udp"
              from_port = 53
              to_port = 53
              cidr = "10.10.0.0/16"
              rule_action = "allow"
            },
            {
              rule_number = 32766
              protocol = "-1"
              from_port = 0
              to_port = 0
              cidr = "0.0.0.0/0"
              rule_action = "deny"
            },
          ]
          outbound = [
            {
              rule_number = 100
              protocol = "-1"
              from_port = 0
              to_port = 0
              cidr = "10.10.0.0/25"
              rule_action = "allow"
            },
            {
              rule_number = 110
              protocol = "-1"
              from_port = 0
              to_port = 0
              cidr = "10.10.4.0/22"
              rule_action = "allow"
            },
            {
              rule_number = 120
              protocol = "tcp"
              from_port = 0
              to_port = 0
              cidr = "0.0.0.0/0"
              rule_action = "allow"
            },
            {
              rule_number = 130
              protocol = "udp"
              from_port = 53
              to_port = 53
              cidr = "10.10.0.0/16"
              rule_action = "allow"
            },
            {
              rule_number = 32766
              protocol = "-1"
              from_port = 0
              to_port = 0
              cidr = "0.0.0.0/0"
              rule_action = "deny"
            }
          ]
        }
      }
    }
  }
}
route_tables = {
  rt1 = {
    vpc_key = "main"
    route_tables = {
      "public-rt" = {
        name = "rt-subnet-bu1-us-east-1-sandbox-public"
        subnet_ids = ["public-a"]
        routes = [
          {
            cidr = "10.10.0.0/25"
            gateway_id = "local"
          },
          /*{
            cidr = "10.10.4.0/22"
            gateway_id = "vpce-netfw"
          },
          {
            cidr = "10.10.0.128/27"
            gateway_id = "vpce-netfw"
          },
          {
            cidr = "0.0.0.0/0"
            gateway_id = "vpce-netfw"
          },*/
        ]
      }
      "private-rt" = {
        name = "rt-subnet-bu1-us-east-1-sandbox-private"
        subnet_ids = ["private-a"]
        routes = [
          {
            cidr = "10.10.4.0/22"
            gateway_id = "local"
          },
          /*{
            cidr = "10.10.0.0/25"
            gateway_id = "vpce-netfw"
          },
          {
            cidr = "10.10.0.128/27"
            gateway_id = "vpce-netfw"
          },
          {
            cidr = "0.0.0.0/0"
            gateway_id = "vpce-netfw"
          },*/
        ]
      }
      "firewall-rt" = {
        name = "rt-subnet-bu1-us-east-1-sandbox-firewall"
        subnet_ids = ["firewall-a"]
        routes = [
          {
            cidr = "10.10.0.0/16"
            gateway_id = "local"
          },
          {
            cidr = "0.0.0.0/0"
            gateway_id = "igw-sandbox"
          },
        ]
      }
      "igw-edge-rt" = {
        name = "rt-igw-edge"
        subnet_ids = []
        routes = [
          /*{
            cidr = "10.10.0.0/25"
            gateway_id = "vpce-netfw"
          },
          {
            cidr = "10.10.4.0/22"
            gateway_id = "vpce-netfw"
          },*/
        ]
      }
    }
  }
}
security_groups = {
  "sg-1" = {
    vpc_key = "main"
    security_groups = {
      app = {
        name = "app1-us-east-1-sandbox-web"
        ingress = [
          {
            from_port = 80
            to_port = 80
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
          },
        ]
        egress = [
          {
            from_port = 0
            to_port = 0
            protocol = "-1"
            cidr_blocks = ["0.0.0.0/0"]
          },
        ]
      }
    }
  }
}
network_firewall = {
  "nfw-1" = {
    vpc_key = "main"
    subnet_key = "subnet-set-1"
    firewall_name = "nfw-bu1-us-east-1-sandbox"
    firewall_policy_name = "prod-firewall-policy"
    stateless_rule_groups = {}
    stateful_rule_groups = {}
    
    managed_rule_groups = {
      "botnet-protection" = {
        name     = "aws-managed-botnet-protection"
        arn      = "arn:aws:wafv2:us-east-1::managed-rule-group/aws-managed-rules/AWSManagedRulesBotControlRuleGroup"
        priority = 1
      }
      "malware-protection" = {
        name     = "aws-managed-malware-protection"
        arn      = "arn:aws:wafv2:us-east-1::managed-rule-group/aws-managed-rules/AWSManagedRulesMalwareProtectionRuleGroup"
        priority = 2
      }
      "threat-signature" = {
        name     = "aws-managed-threat-signature"
        arn      = "arn:aws:wafv2:us-east-1::managed-rule-group/aws-managed-rules/AWSManagedRulesThreatSignatureRuleGroup"
        priority = 3
      }
    }
    
    enable_logging = true
    logging_destinations = []
  }
}
budgets = {
  "budget-1" = {
    budgets = {
      monthly = {
        name = "monthly-prod-budget"
        budget_type = "COST"
        amount = "1000"
        time_unit = "MONTHLY"
        notifications = [
          {
            threshold = 70
            threshold_type = "PERCENTAGE"
            comparison = "GREATER_THAN"
            notification_type = "ACTUAL"
            emails = ["kowsik.chowdhury@aon.com"]
          },
          {
            threshold = 85
            threshold_type = "PERCENTAGE"
            comparison = "GREATER_THAN"
            notification_type = "ACTUAL"
            emails = ["kowsik.chowdhury@aon.com"]
          },
          {
            threshold = 95
            threshold_type = "PERCENTAGE"
            comparison = "GREATER_THAN"
            notification_type = "ACTUAL"
            emails = ["kowsik.chowdhury@aon.com"]
          },
        ]
      }
    }
  }
}
