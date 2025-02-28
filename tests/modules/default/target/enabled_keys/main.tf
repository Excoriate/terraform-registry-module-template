module "this" {
  source = "../../../../../modules/default"

  # Module is explicitly enabled
  is_enabled = true

  # Tags with specific keys for testing
  tags = {
    Environment = "test"
    Terraform   = "true"
    Module      = "default"
    Test        = "enabled_keys"
    Owner       = "DevOps"
    CostCenter  = "12345"
  }
}

# Output the module's enabled status
output "is_enabled" {
  description = "Whether the module is enabled"
  value       = module.this.is_enabled
}

# Output the module's tags
output "tags" {
  description = "The tags applied to resources"
  value       = module.this.tags
}
