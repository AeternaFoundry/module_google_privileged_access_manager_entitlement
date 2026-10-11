variable "privileged_access_manager_entitlements" {
  description = <<EOT
Map of privileged_access_manager_entitlements, attributes below
Required:
    - entitlement_id
    - location
    - max_request_duration
    - parent
    - eligible_users (block):
        - principals (required)
    - privileged_access (block):
        - gcp_iam_access (required, block):
            - resource (required)
            - resource_type (required)
            - role_bindings (required, block):
                - condition_expression (optional)
                - role (required)
    - requester_justification_config (block):
        - not_mandatory (optional, block):
        - unstructured (optional, block):
Optional:
    - deletion_policy
    - additional_notification_targets (block):
        - admin_email_recipients (optional)
        - requester_email_recipients (optional)
    - approval_workflow (block):
        - manual_approvals (required, block):
            - require_approver_justification (optional)
            - steps (required, block):
                - approvals_needed (optional)
                - approver_email_recipients (optional)
                - approvers (required, block):
                    - principals (required)
    - timeouts (block):
        - create (optional)
        - delete (optional)
        - update (optional)
EOT

  type = map(object({
    entitlement_id       = string
    location             = string
    max_request_duration = string
    parent               = string
    deletion_policy      = optional(string)
    eligible_users = list(object({
      principals = set(string)
    }))
    privileged_access = object({
      gcp_iam_access = object({
        resource      = string
        resource_type = string
        role_bindings = list(object({
          condition_expression = optional(string)
          role                 = string
        }))
      })
    })
    requester_justification_config = object({
      not_mandatory = optional(object({
      }))
      unstructured = optional(object({
      }))
    })
    additional_notification_targets = optional(object({
      admin_email_recipients     = optional(set(string))
      requester_email_recipients = optional(set(string))
    }))
    approval_workflow = optional(object({
      manual_approvals = object({
        require_approver_justification = optional(bool)
        steps = list(object({
          approvals_needed          = optional(number)
          approver_email_recipients = optional(set(string))
          approvers = object({
            principals = set(string)
          })
        }))
      })
    }))
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      update = optional(string)
    }))
  }))
  validation {
    condition = alltrue([
      for k, v in var.privileged_access_manager_entitlements : (
        length(v.eligible_users) >= 1
      )
    ])
    error_message = "Each eligible_users list must contain at least 1 items"
  }
  validation {
    condition = alltrue([
      for k, v in var.privileged_access_manager_entitlements : (
        length(v.privileged_access.gcp_iam_access.role_bindings) >= 1
      )
    ])
    error_message = "Each role_bindings list must contain at least 1 items"
  }
  validation {
    condition = alltrue([
      for k, v in var.privileged_access_manager_entitlements : (
        v.approval_workflow == null || (length(v.approval_workflow.manual_approvals.steps) >= 1)
      )
    ])
    error_message = "Each steps list must contain at least 1 items"
  }
  # Note: 3 additional provider-side validators are enforced at apply time but not mirrored as validation{} blocks here (bespoke or non-mechanically-translatable).
}

