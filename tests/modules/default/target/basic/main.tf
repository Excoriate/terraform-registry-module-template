###################################
# Target Test Configuration for Default Module 🎯
# ----------------------------------------------------
#
# This configuration demonstrates a basic use case
# for the default module, showcasing its core functionality
# and configuration options.
#
###################################

terraform {
  required_version = ">= 1.10.0"

  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.0"
    }
  }
}

# Module instantiation with basic configuration
module "this" {
  source = "../../../../../modules/default"

  is_enabled = var.is_enabled
  tags       = var.tags
}

# Optional: Output module results for verification
output "module_is_enabled" {
  description = "Confirm module is enabled"
  value       = module.this.is_enabled
}

output "module_tags" {
  description = "Verify tags applied to the module"
  value       = module.this.tags_set
}

variable "is_enabled" {
  type        = bool
  description = "Whether the module is enabled or not."
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources."
  default = {
    environment = "testing"
    module      = "default"
    purpose     = "terratest-validation"
    managed-by  = "terraform"
  }
}
