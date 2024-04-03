output "is_enabled" {
  value       = var.is_enabled
  description = "Whether the module is enabled or not."
}

output "tags_set" {
  value       = var.tags
  description = "The tags set for the module."
}

###################################
# Module-Specific Outputs 🚀
# ----------------------------------------------------
#
# These outputs are specific to the functionality provided by this module.
# They offer insights and access points into the resources created or managed by this module.
#
# (Add your module-specific outputs here, with a brief description for each)
#
###################################

# Example of a module-specific output:
# output "queue_url" {
#   value       = aws_sqs_queue.main.url
#   description = "The URL of the created SQS queue."
# }

# output "dlq_url" {
#   value       = aws_sqs_queue.dlq.url
#   description = "The URL of the created Dead Letter Queue (DLQ)."
# }
