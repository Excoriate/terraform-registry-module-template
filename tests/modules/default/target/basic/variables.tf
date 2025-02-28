###################################
# Test Configuration Variables
# ----------------------------------------------------
#
# Variables used to configure the test module
#
###################################

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
