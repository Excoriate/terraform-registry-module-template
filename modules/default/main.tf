resource "random_string" "random_text" {
  for_each = var.is_enabled ? { is_enabled = true} : {}
  length  = 10
  special = false
}
