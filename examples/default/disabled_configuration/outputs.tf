output "is_enabled" {
  description = "Whether the module is enabled or not"
  value       = module.this.is_enabled
}

output "tags_set" {
  description = "The tags set for the module"
  value       = module.this.tags_set
}
