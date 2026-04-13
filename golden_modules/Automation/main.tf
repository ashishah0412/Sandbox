
############################################
# AWS COST BUDGET (Dynamic)
############################################
resource "aws_budgets_budget" "this" {
  for_each = var.budgets

  name              = each.value.name
  budget_type       = each.value.budget_type
  limit_amount      = each.value.amount
  limit_unit        = "USD"
  time_unit         = each.value.time_unit

  cost_types {
    include_credit             = try(each.value.cost_types.include_credit, false)
    include_other_subscription = try(each.value.cost_types.include_other_subscription, false)
    include_recurring          = try(each.value.cost_types.include_recurring, true)
    include_refund             = try(each.value.cost_types.include_refund, false)
    include_subscription       = try(each.value.cost_types.include_subscription, true)
    include_support            = try(each.value.cost_types.include_support, true)
    include_tax                = try(each.value.cost_types.include_tax, true)
    include_upfront            = try(each.value.cost_types.include_upfront, true)
    use_blended                = try(each.value.cost_types.use_blended, false)
    use_amortized              = try(each.value.cost_types.use_amortized, false)
  }

  ############################################
  # NOTIFICATIONS (Dynamic per Budget)
  ############################################
  dynamic "notification" {
    for_each = each.value.notifications

    content {
      comparison_operator = notification.value.comparison
      threshold           = notification.value.threshold
      threshold_type      = notification.value.threshold_type
      notification_type   = notification.value.notification_type # ACTUAL | FORECASTED

      subscriber_email_addresses = lookup(notification.value, "emails", [])
      subscriber_sns_topic_arns  = lookup(notification.value, "sns_arns", [])
    }
  }

  ############################################
  # TAGS
  ############################################
  tags = merge(
    { Name = each.value.name },
    var.tags,
    lookup(each.value, "tags", {})
  )
}
