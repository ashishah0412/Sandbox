
############################################
# BUDGET INPUT MAP
#
# Example:
# budgets = {
#   monthly-budget = {
#     name        = "monthly-prod-budget"
#     budget_type = "COST"
#     amount      = "500"
#     time_unit   = "MONTHLY"
#
#     cost_filters = {
#       Service = ["AmazonEC2"]
#     }
#
#     notifications = [
#       {
#         threshold        = 80
#         threshold_type   = "PERCENTAGE"
#         comparison       = "GREATER_THAN"
#         notification_type = "ACTUAL"
#         emails           = ["ops@example.com"]
#       }
#     ]
#   }
# }
############################################

variable "budgets" {
  type = map(object({
    name        = string
    budget_type = string     # COST | USAGE | SAVINGS_PLANS | RI_UTILIZATION | RI_COVERAGE
    amount      = string     # e.g., "500"
    time_unit   = string     # DAILY | MONTHLY | QUARTERLY | ANNUALLY

    cost_filters = optional(map(list(string)))
    cost_types   = optional(map(bool))

    notifications = list(object({
      threshold         = number
      threshold_type    = string   # PERCENTAGE | ABSOLUTE_VALUE
      comparison        = string   # GREATER_THAN | LESS_THAN | EQUAL_TO
      notification_type = string   # ACTUAL | FORECASTED
      emails            = optional(list(string))
      sns_arns          = optional(list(string))
    }))

    # Optional: auto-apply SCP action when budget threshold is reached.
    # If subscriber_emails/subscriber_sns_arns are omitted, subscribers are
    # inherited from the 95% ACTUAL notification for the same budget.
    scp_action = optional(object({
      policy_id           = string
      target_ids          = list(string)
      execution_role_name = string           # Role name only — ARN is built from current account automatically
      account_id          = optional(string)
      threshold          = optional(number, 95)
      threshold_type     = optional(string, "PERCENTAGE")
      notification_type  = optional(string, "ACTUAL")
      subscriber_emails  = optional(list(string), [])
      subscriber_sns_arns = optional(list(string), [])
    }))

    tags = optional(map(string))
  }))
}

############################################
# Global Tags
############################################
variable "tags" {
  type    = map(string)
  default = {}
}
