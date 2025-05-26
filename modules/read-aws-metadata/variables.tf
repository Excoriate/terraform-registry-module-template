###################################
# Terraform Module Variables 🛠️
# ----------------------------------------------------
#
# Configurable parameters for flexible module deployment
# Follows best practices for clear, informative variable definitions
#
###################################

variable "is_enabled" {
  type        = bool
  description = <<-DESC
  Toggle module data source execution.

  Use cases:
  - Conditional data source execution
  - Environment-specific deployments
  - Cost and resource management

  Examples:
  ```hcl
  # Disable all module data sources
  is_enabled = false

  # Enable module data sources (default)
  is_enabled = true
  ```

  🔗 References:
  - Terraform Variables: https://terraform.io/language/values/variables
  - Module Patterns: https://hashicorp.com/blog/terraform-module-composition
  DESC
  default     = true
}
