resource "random_string" "random_text" {
  length  = 10
  special = false
}

output "output_text" {
  value = random_string.random_text.result
}
