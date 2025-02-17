locals {
  ###################################
  # Feature Flags ⛳️
  # ----------------------------------------------------
  #
  # These flags are used to enable or disable certain features.
  # 1. `is_queue_enabled` - Flag to enable or disable the SQS queue that's built-in to the module.
  # 2. `is_dlq_enabled` - Flag to enable or disable the Dead Letter Queue (DLQ) that's built-in to the module.
  #
  ###################################
  is_enabled = var.is_enabled
}
