module "target" {
  source     = "../../../../../modules/default"
  is_enabled = var.is_enabled
}


# ----------------------------------
# Emulate input variables required by
# the target module
# ----------------------------------
variable "is_enabled" {
  type = bool
}

# ----------------------------------
# Emulate output variables provided by
# the target module
# ----------------------------------
output "is_enabled" {
  value = var.is_enabled
}
