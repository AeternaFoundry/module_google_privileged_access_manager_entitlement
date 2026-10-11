resource "google_privileged_access_manager_entitlement" "privileged_access_manager_entitlements" {
  for_each = var.privileged_access_manager_entitlements

  entitlement_id       = each.value.entitlement_id
  location             = each.value.location
  max_request_duration = each.value.max_request_duration
  parent               = each.value.parent
  deletion_policy      = each.value.deletion_policy

  dynamic "eligible_users" {
    for_each = each.value.eligible_users
    content {
      principals = eligible_users.value.principals
    }
  }

  privileged_access {
    gcp_iam_access {
      resource      = each.value.privileged_access.gcp_iam_access.resource
      resource_type = each.value.privileged_access.gcp_iam_access.resource_type
      dynamic "role_bindings" {
        for_each = each.value.privileged_access.gcp_iam_access.role_bindings
        content {
          condition_expression = role_bindings.value.condition_expression
          role                 = role_bindings.value.role
        }
      }
    }
  }

  requester_justification_config {
    dynamic "not_mandatory" {
      for_each = each.value.requester_justification_config.not_mandatory != null ? [each.value.requester_justification_config.not_mandatory] : []
      content {
      }
    }
    dynamic "unstructured" {
      for_each = each.value.requester_justification_config.unstructured != null ? [each.value.requester_justification_config.unstructured] : []
      content {
      }
    }
  }

  dynamic "additional_notification_targets" {
    for_each = each.value.additional_notification_targets != null ? [each.value.additional_notification_targets] : []
    content {
      admin_email_recipients     = additional_notification_targets.value.admin_email_recipients
      requester_email_recipients = additional_notification_targets.value.requester_email_recipients
    }
  }

  dynamic "approval_workflow" {
    for_each = each.value.approval_workflow != null ? [each.value.approval_workflow] : []
    content {
      manual_approvals {
        require_approver_justification = approval_workflow.value.manual_approvals.require_approver_justification
        dynamic "steps" {
          for_each = approval_workflow.value.manual_approvals.steps
          content {
            approvals_needed          = steps.value.approvals_needed
            approver_email_recipients = steps.value.approver_email_recipients
            approvers {
              principals = steps.value.approvers.principals
            }
          }
        }
      }
    }
  }

  dynamic "timeouts" {
    for_each = each.value.timeouts != null ? [each.value.timeouts] : []
    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      update = timeouts.value.update
    }
  }
}

