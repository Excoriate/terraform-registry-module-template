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

  ###################################
  # Normalized & CLeaned Variables 🧹
  # ----------------------------------------------------
  #
  # These variables are used to normalize and clean the input variables.
  # 1. `queue_name` - The name of the queue. This is normalized to remove any leading or trailing whitespace.
  # 2. `queue_name_fifo` - The name of the FIFO queue. This is normalized to remove any leading or trailing whitespace.
  # 3. `dlq_name` - The name of the Dead Letter Queue (DLQ). This is normalized to remove any leading or trailing whitespace.
  # 4. `dlq_name_fifo` - The name of the FIFO Dead Letter Queue (DLQ). This is normalized to remove any leading or trailing whitespace.
  #
  ###################################
}
