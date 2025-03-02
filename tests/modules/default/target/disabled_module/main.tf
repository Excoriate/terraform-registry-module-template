module "this" {
  source = "../../../../../modules/default"

  # Module is explicitly disabled
  is_enabled = false

  # Tags that should not be applied when module is disabled
  tags = {
    Environment = "test"
    Terraform   = "true"
    Module      = "default"
    Test        = "disabled_configuration"
  }
}

# Output the module's enabled status
output "is_enabled" {
  description = "Whether the module is enabled"
  value       = module.this.is_enabled
}

# Output the module's tags (should be empty when disabled)
output "tags" {
  description = "The tags applied to resources (should be empty when disabled)"
  value       = module.this.tags_set
}

terraform {
  required_version = ">= 1.10.0"

  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "3.6.2"
    }
  }
}
