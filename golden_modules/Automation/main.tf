
############################################
# AWS COST BUDGET (Dynamic)
############################################
data "aws_caller_identity" "current" {}

locals {
  budgets_with_scp_action = {
    for budget_key, budget_cfg in var.budgets : budget_key => budget_cfg
    if try(budget_cfg.scp_action, null) != null
  }

  scp_action_subscribers = {
    for budget_key, budget_cfg in local.budgets_with_scp_action : budget_key => concat(
      [
        for email in try(budget_cfg.scp_action.subscriber_emails, []) : {
          address           = email
          subscription_type = "EMAIL"
        }
      ],
      [
        for sns_arn in try(budget_cfg.scp_action.subscriber_sns_arns, []) : {
          address           = sns_arn
          subscription_type = "SNS"
        }
      ],
      (
        length(try(budget_cfg.scp_action.subscriber_emails, [])) == 0 &&
        length(try(budget_cfg.scp_action.subscriber_sns_arns, [])) == 0
      ) ? concat(
        flatten([
          for n in budget_cfg.notifications : [
            for email in coalesce(try(n.emails, null), []) : {
              address           = email
              subscription_type = "EMAIL"
            }
            if n.threshold == 95 && n.threshold_type == "PERCENTAGE" && n.notification_type == "ACTUAL"
          ]
        ]),
        flatten([
          for n in budget_cfg.notifications : [
            for sns_arn in coalesce(try(n.sns_arns, null), []) : {
              address           = sns_arn
              subscription_type = "SNS"
            }
            if n.threshold == 95 && n.threshold_type == "PERCENTAGE" && n.notification_type == "ACTUAL"
          ]
        ])
      ) : []
    )
  }
}

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

resource "aws_budgets_budget_action" "scp_95" {
  for_each = local.budgets_with_scp_action

  budget_name        = aws_budgets_budget.this[each.key].name
  action_type        = "APPLY_SCP_POLICY"
  approval_model     = "AUTOMATIC"
  notification_type  = try(each.value.scp_action.notification_type, "ACTUAL")
  # Role must be in the same account as the budget action. Always use current account ID.
  execution_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${each.value.scp_action.execution_role_name}"
  account_id         = data.aws_caller_identity.current.account_id

  action_threshold {
    action_threshold_type  = try(each.value.scp_action.threshold_type, "PERCENTAGE")
    action_threshold_value = try(each.value.scp_action.threshold, 95)
  }

  definition {
    scp_action_definition {
      policy_id  = each.value.scp_action.policy_id
      target_ids = each.value.scp_action.target_ids
    }
  }

  dynamic "subscriber" {
    for_each = local.scp_action_subscribers[each.key]

    content {
      address           = subscriber.value.address
      subscription_type = subscriber.value.subscription_type
    }
  }

  tags = merge(
    { Name = "${each.value.name}-scp-action" },
    var.tags,
    lookup(each.value, "tags", {})
  )

  lifecycle {
    precondition {
      condition     = length(local.scp_action_subscribers[each.key]) > 0
      error_message = "scp_action requires at least one subscriber. Provide scp_action subscriber_emails/subscriber_sns_arns or define subscribers in the 95% ACTUAL budget notification."
    }
  }
}
