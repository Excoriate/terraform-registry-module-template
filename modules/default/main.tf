resource "random_string" "random_text" {
  for_each = local.is_enabled
  length   = 10
  special  = false
}
