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
  Toggle module resource creation.

  Use cases:
  - Conditional resource provisioning
  - Environment-specific deployments
  - Cost and resource management

  Examples:
  ```hcl
  # Disable all module resources
  is_enabled = false

  # Enable module resources (default)
  is_enabled = true
  ```

  🔗 References:
  - Terraform Variables: https://terraform.io/language/values/variables
  - Module Patterns: https://hashicorp.com/blog/terraform-module-composition
  DESC
  default     = true
}

variable "tags" {
  type        = map(string)
  description = <<-DESC
  Resource tagging for organization and governance.

  Key benefits:
  - Resource tracking
  - Cost allocation
  - Compliance management

  Best practices:
  - Use lowercase, hyphen-separated keys
  - Include context (env, project, ownership)

  Examples:
  ```hcl
  tags = {
    environment = "production"
    project     = "core-infra"
    managed-by  = "terraform"
  }
  ```

  🔗 References:
  - AWS Tagging: https://aws.amazon.com/answers/account-management/aws-tagging-strategies/
  - Cloud Tagging: https://cloud.google.com/resource-manager/docs/best-practices-labels
  DESC
  default     = {}
}
